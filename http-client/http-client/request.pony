
class val Request
	let _uri: URI
	let _method: String = "GET" // TODO make other methods available
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
			.>append("HTTP/1.1")
		result
