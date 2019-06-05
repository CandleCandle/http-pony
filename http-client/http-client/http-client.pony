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
			recover HttpConnectionNotify end,
			request'.uri().host,
			request'.uri().port
			)

class HttpConnectionNotify is TCPConnectionNotify
	fun ref received(
		conn: TCPConnection ref,
		data: Array[U8] iso,
		times: USize
		): Bool =>
		conn.close()
		true

	fun ref connected(conn: TCPConnection ref) =>
		None

	fun ref connect_failed(conn: TCPConnection ref) =>
		None

//actor HttpConnection



// vi: sw=4 sts=4 ts=4 noet
