use "collections"
use "promises"
use "net"
use "net/ssl"

primitive ErrorConnect
primitive ErrorTimeoutConnect
primitive ErrorTimeoutIntraByte
primitive ErrorSSLInit
primitive ErrorSSLHandshake

type HttpResult is ( Response val | ErrorConnect | ErrorTimeoutConnect | ErrorTimeoutIntraByte | ErrorSSLInit | ErrorSSLHandshake )

trait tag HttpClient
	fun tag request(request': Request val): Promise[HttpResult]

actor PoolingHttpClient is HttpClient
	let _timeout_connect: U128 // nanos
	let _timeout_intra_byte: U128 // nanos
// TODO	let _connections: Map[String, HttpConnection] // unused connection pool

	new create(timeout_connect: U128, timeout_intra_byte: U128) =>
		_timeout_connect = timeout_connect
		_timeout_intra_byte = timeout_intra_byte

	fun tag request(request': Request val): Promise[HttpResult] =>
		let p = Promise[HttpResult]
		p(ErrorConnect)
		p

actor SimpleHttpClient is HttpClient
	let _timeout_connect: U128 // nanos
	let _timeout_intra_byte: U128 // nanos
	let _auth: TCPConnectAuth
	let _ssl: ( SSLContext | None )
	let _proxy: Proxy val

	new create(auth: TCPConnectAuth, ssl: ( SSLContext | None ) = None, proxy: Proxy val = NoProxy, timeout_connect: U128, timeout_intra_byte: U128) =>
		_auth = auth
		_ssl = ssl
		_proxy = proxy
		_timeout_connect = timeout_connect
		_timeout_intra_byte = timeout_intra_byte

	fun tag request(request': Request val): Promise[HttpResult] =>
		let p = Promise[HttpResult]
		_request(request', p)
		p

	be _request(request': Request val, p: Promise[HttpResult]) =>
		var notify: ( None | TCPConnectionNotify iso ) = match _ssl
			| None => recover HttpConnectionNotify(request', p) end
			| let ssl: SSLContext =>
				try
					SSLConnection(
						HttpConnectionNotify(request', p),
						ssl.client(request'.uri().host)?
						)
				else p(ErrorSSLInit) end
			end
		match notify = None
		| let notify': TCPConnectionNotify iso =>
			TCPConnection(
				_auth,
				_proxy(consume notify'),
				request'.uri().host,
				request'.uri().port
				)
		end

class iso HttpConnectionNotify is TCPConnectionNotify
	let _parser: ClientParser = CompleteParser

	// This pair should be paired; so that the correct promise is fulfilled when a request completes.
	var _request: Request val // TODO make this a list of Requests
	var _responder: Promise[HttpResult] // TODO make this a list of Promise; that get fulfilled in-order when connections are re-used.

	new iso create(request: Request val, responder: Promise[HttpResult]) =>
		_request = request
		_responder = responder

	fun ref connecting(conn: TCPConnection ref, count: U32) =>
		None

	fun ref auth_failed(conn: TCPConnection ref) =>
		_responder(ErrorSSLHandshake)

	fun ref received(
		conn: TCPConnection ref,
		data: Array[U8] iso,
		times: USize
		): Bool =>

		match _parser.apply(consume data)
		| let r: HttpResult => 
			_responder(r)
			conn.close() // TODO send the next request in the list?
		end
		true

	fun ref connected(conn: TCPConnection ref) =>
		conn.write(_request.to_request())

	fun ref connect_failed(conn: TCPConnection ref) =>
		_responder(ErrorConnect)


// vi: sw=4 sts=4 ts=4 noet
