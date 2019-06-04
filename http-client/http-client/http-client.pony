use "collections"
use "promises"
use "net"

trait Header
	fun apply(): String val

primitive HeaderContentLength is Header
	fun apply(): String val => "Content-Length"
	fun parse(value: String): USize ? => value.usize()?


class Response
	var response_code: U16
	let headers: Array[(String, String)] // Headers are ordered and can be repeated.
	let body: Array[Array[U8] val]

	new trn empty() =>
		response_code = 0
		headers = Array[(String, String)]
		body = Array[Array[U8] val]

	// new val create(response_code': U16, headers': Array[(String, String)] val, body': Array[Array[U8] val] val) =>
	// 	response_code = response_code'
	// 	headers = headers'
	// 	body = body'

	fun ref add_header(k: String, v: String) =>
		"""
		Add the k/v pair as a header. both k and v should have no trailing or leading whitespace
		"""
		headers.push((k, v))

	fun ref first_header(k': Header val): String ? =>
		"""
		returns the value of the first example of the specified header. Will not error if `has_header` has returned `true`
		"""
		for (k, v) in headers.values() do
			if k == k'() then
				return v
			end
		end
		error

	fun box has_header(k': Header val): Bool =>
		"""
		Check if the response contains the specified header.
		"""
		for (k, v) in headers.values() do
			if k == k'() then
				return true
			end
		end
		false

	fun ref add_body(data: Array[U8] val) =>
		body.push(data)

	fun body_as_str(): String =>
		let result = recover trn String end
		for a in body.values() do
			result.append(a)
		end
		result

	fun body_size(): USize =>
		var result: USize = 0
		for a in body.values() do
			result = result + a.size()
		end
		result


primitive TimeoutErrorConnect
primitive TimeoutErrorIntraByte

type HttpResult is ( Response val | TimeoutErrorConnect | TimeoutErrorIntraByte )

class val URI is Stringable
	let scheme: String
	// authentication
	let host: String
	let port: String
	let path: String // never 'None', minimum is "/"
	let query: (String | None)
	let fragment: (String | None)

	new val create(scheme': String, host': String, port': String, path': String, query': (String | None) = None, fragment': (String | None) = None) =>
		scheme = scheme'
		host = host'
		port = port'
		path = path'
		query = query'
		fragment = fragment'

	// TODO new parse(uri: String) => ...

	fun string(): String iso^ =>
		recover iso 
			let s = String()
			s.>append(scheme)
				.>append("://")
				.>append(host)
				.>append(":")
				.>append(port)
				.>append(path)
			match query
			| let q: String => s.>append("?").append(q)
			end
			match fragment
			| let f: String => s.>append("#").append(f)
			end
			s
		end

class val Request
	let _uri: URI
	let _timeout_connect: (None | U128) // nanos
	let _timeout_intra_byte: (None | U128) // nanos

	new val create(uri': URI) =>
		_uri = uri'
		_timeout_connect = None
		_timeout_intra_byte = None
	
	new val with_timeouts(uri': URI, timeout_connect: U128, timeout_intra_byte: U128) =>
		_uri = uri'
		_timeout_connect = timeout_connect
		_timeout_intra_byte = timeout_intra_byte

	fun uri(): URI => _uri

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
