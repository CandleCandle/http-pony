use "text-reader"

primitive _ParserStateReady
primitive _ParserStateHeader
primitive _ParserStateBody
type _ParserState is ( _ParserStateReady | _ParserStateHeader | _ParserStateBody )

trait ClientParser
	fun ref apply(data: Array[U8] iso): ( None | HttpResult )
		"""
		Take a section of data and parse it into a HttpResult
		Returns:
			None when more data is required
			HttpResult when a complete result is available.
		"""

class IncrementalParser is ClientParser
	let _reader: LineReader = LineReader
	var _response: Response trn = Response.empty()
	var _state: _ParserState = _ParserStateReady

	new create() =>
		None

	fun ref apply(data: Array[U8] iso): ( None | HttpResult ) =>
		match _state
		| _ParserStateBody =>
			_response.add_body(consume data) // TODO assumption that `data` does not contain the end of one body and the start of the next response.
		else
			_reader.apply(consume data)
		end
		while _reader.has_line() do
			match _state
			| _ParserStateReady => _parse_status_line(_reader.read_line())
			| _ParserStateHeader => _parse_header(_reader.read_line())
			end
		end
		try
			if _response.has_header(HeaderContentLength) then
				let expected = HeaderContentLength.parse(_response.first_header(HeaderContentLength)?)?
				if _response.body_size() >= expected then
					reset()
				end
			end
		end
	
	fun ref reset(): Response val =>
		_state = _ParserStateReady
		_response = Response.empty()

	fun ref _parse_status_line(line: String) =>
		_response.response_code = 200
		_state = _ParserStateHeader

	fun ref _parse_header(line: String) =>
		if line.size() == 0 then
			_state = _ParserStateBody
			let remaining = _reader.remaining()
			for b in remaining.values() do
				match b
				| let s: String val => _response.add_body(s.array())
				| let a: Array[U8] val => _response.add_body(a)
				end
			end
			return
		end

		let key = recover trn String end
		let value = recover trn String end
		var key_finished = false
		for c in line.array().values() do
			if c == ':' then
				key_finished = true
			else
				if key_finished then
					value.push(c)
				else
					key.push(c)
				end
			end
		end
		key.strip()
		value.strip()
		_response.add_header(consume key, consume value)






// vi: sw=4 sts=4 ts=4 noet