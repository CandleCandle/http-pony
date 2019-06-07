
primitive HttpVersion10 fun apply(): String val => "HTTP/1.0"
primitive HttpVersion11 fun apply(): String val => "HTTP/1.1"
type HttpVersion is ( HttpVersion10 | HttpVersion11 )
primitive HttpVersions fun apply(): Array[HttpVersion] val => [HttpVersion10; HttpVersion11]

class Request
	let _uri: URI
	var _http_version: HttpVersion = HttpVersion11
	var _method: String = "GET" // TODO make other methods available
	var _timeout_connect: (None | U128) // nanos
	var _timeout_intra_byte: (None | U128) // nanos
	let _headers: Array[(String val, String val)] = Array[(String val, String val)]

	new ref create(uri': URI) =>
		_uri = uri'
		_timeout_connect = None
		_timeout_intra_byte = None
	
	fun ref with_connect_timeouts(timeout_connect: U128) =>
		_timeout_connect = timeout_connect

	fun ref with_intra_byte_timeout(timeout_intra_byte: U128) =>
		_timeout_intra_byte = timeout_intra_byte

	fun ref with_method(method: String val) =>
		_method = method

	fun ref with_header(k: ( String val | Header val ), v: String val) =>
		let h: (String val, String val) = match k
			| let k': String val => (k', v)
			| let k': Header val => (k'(), v)
			end
		_headers.push(h)

	fun box uri(): URI => _uri

	fun box request_line(): String val =>
		let result: String trn = recover trn String end
		result.>append(_method)
			.>append(" ")
			.>append(_uri.path)
		match _uri.query
		| let q: String =>
			result.>append("?")
				.>append(q)
		end
		result.>append(" ")
			.>append(_http_version())
		result

	fun box to_request(): String val => // TODO poor name; needs to be something along the lines of "converts this request object to something that can be sent over the wire."
		let result: String trn = recover trn String end
		result.>append(request_line()).>append("\r\n")
		for h in _headers.values() do
			result.>append(h._1).>append(": ").>append(h._2).>append("\r\n")
		end
		// headers
		result.>append("\r\n")
		// request body
		result

