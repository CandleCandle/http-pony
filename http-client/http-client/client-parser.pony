use "text-reader"

primitive _ParserStateReady fun val apply(): String val => "_ParserStateReady"
primitive _ParserStateHeader fun val apply(): String val => "_ParserStateHeader"
primitive _ParserStateBody fun val apply(): String val => "_ParserStateReady"
type _ParserState is ( _ParserStateReady | _ParserStateHeader | _ParserStateBody )

trait ClientParser
	fun ref apply(data: Array[U8] iso): ( None | HttpResult )
		"""
		Take a section of data and parse it into a HttpResult
		Returns:
			None when more data is required
			HttpResult when a complete result is available.
		"""

primitive _Header
	fun last(line: String, cb: {(ByteSeq)} ref): Bool =>
		line.size() == 0

	fun apply(line: String): (String, String) =>
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
		(consume key, consume value)

primitive _StatusLine
	fun apply(line: String): U16 =>
		try
			let start = line.find(" ")?
			let finish = line.find(" ", 0, 1)?
			line.substring(start+1, finish).u16()?
		else 500 end

class StreamingParser is ClientParser
	let _reader: LineReader = LineReader
	var _response: Response trn = Response.empty()
	var _state: _ParserState = _ParserStateReady

	let _callback: {(Array[U8] iso)} iso

	new create(callback: {(Array[U8] iso)} iso) =>
		_callback = consume callback

	fun ref apply(data: Array[U8] iso): ( None | HttpResult ) =>
		match _state
		| _ParserStateBody =>
			_callback(consume data)
			return
		else
			_reader.apply(consume data)
		end
		while _reader.has_line() do
			None
			// match _state
			// | _ParserStateReady =>
			// 	_response.status_code = _StatusLine(_reader.read_line())
			// 	_state = _ParserStateHeader
			// | _ParserStateHeader =>
			// 	None
			// 	// let line: _reader.read_line()
			// 	// if _Header.last(line, {(b: (String | Array[U8])) =>
			// 	// 		// match b
			// 	// 		// | let s: String val => callback(s.array())
			// 	// 		// | let a: Array[U8] val => callback(a)
			// 	// 		// end
			// 	// 	})
			//	// 	_state = _ParserStateBody
			// 	// else
			// 	// 	(let k, let v) = _Header(line)
			// 	// 	_response.add_header(k, v)
			// 	// end
			// end
		end

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
			| _ParserStateReady =>
				_response.response_code = _StatusLine(_reader.read_line())
			| _ParserStateHeader =>
				None
			end
			// match _state
			// | _ParserStateReady => 
			// 	)
			// 	_state = _ParserStateHeader
			// | _ParserStateHeader =>
			// 	let line: _reader.read_line()
			// 	if _Header.last(line, {(b: (String | Array[U8])) =>
			// 			match b
			// 			| let s: String val => _response.add_body(s.array())
			// 			| let a: Array[U8] val => _response.add_body(a)
			// 			end
			// 		}
			//		_state = _ParserStateBody)
			// 	else
			// 		(let k, let v) = _Header(line)
			// 		_response.add_header(k, v)
			// 	end
			// end
		end
		try
			match _state
			| _ParserStateBody =>
				if _response.has_header(HeaderContentLength) then
					let expected = HeaderContentLength.parse(_response.first_header(HeaderContentLength)?)?
					if _response.body_size() >= expected then
						reset()
					end
				end
			end
		end
	
	fun ref reset(): Response val =>
		_state = _ParserStateReady
		_response = Response.empty()

	fun ref _parse_status_line(line: String) =>

		_state = _ParserStateHeader







// vi: sw=4 sts=4 ts=4 noet