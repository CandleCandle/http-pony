
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
