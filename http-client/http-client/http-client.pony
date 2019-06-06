use "collections"
use "promises"
use "net"

primitive TimeoutErrorConnect
primitive TimeoutErrorIntraByte

type HttpResult is ( Response val | TimeoutErrorConnect | TimeoutErrorIntraByte )

trait HttpClient
	fun request(request': Request): Promise[HttpResult]

actor PoolingHttpClient is HttpClient
	let _timeout_connect: U128 // nanos
	let _timeout_intra_byte: U128 // nanos
// TODO	let _connections: Map[String, HttpConnection] // unused connection pool

	new create(timeout_connect: U128, timeout_intra_byte: U128) =>
		_timeout_connect = timeout_connect
		_timeout_intra_byte = timeout_intra_byte

	fun tag request(request': Request): Promise[HttpResult] =>
		let p = Promise[HttpResult]
		p(TimeoutErrorConnect)
		p

actor SimpleHttpClient is HttpClient
	let _timeout_connect: U128 // nanos
	let _timeout_intra_byte: U128 // nanos
	let _auth: AmbientAuth

	new create(auth: AmbientAuth, timeout_connect: U128, timeout_intra_byte: U128) =>
		_auth = auth
		_timeout_connect = timeout_connect
		_timeout_intra_byte = timeout_intra_byte

	fun tag request(request': Request val): Promise[HttpResult] =>
		let p = Promise[HttpResult]
		_request(request', p)
		p

	be _request(request': Request val, p: Promise[HttpResult]) =>
		TCPConnection(
			_auth,
			recover HttpConnectionNotify(request', p) end,
			request'.uri().host,
			request'.uri().port
			)

class HttpConnectionNotify is TCPConnectionNotify
	let _parser: ClientParser = IncrementalParser

	// This pair should be paired; so that the correct promise is fulfilled when a request completes.
	var _request: Request val // TODO make this a list of Requests
	var _responder: Promise[HttpResult] // TODO make this a list of Promise; that get fulfilled in-order when connections are re-used.

	new create(request: Request val, responder: Promise[HttpResult]) =>
		_request = request
		_responder = responder

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
		_responder(TimeoutErrorConnect)

//actor HttpConnection



// vi: sw=4 sts=4 ts=4 noet
