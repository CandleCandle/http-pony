
use "../net-clone3"

interface Proxy
	fun apply(wrap: TCPConnectionNotify iso): TCPConnectionNotify iso^

class val NoProxy is Proxy
	fun apply(wrap: TCPConnectionNotify iso): TCPConnectionNotify iso^ => wrap

class val HttpProxy is Proxy
	let _host: String
	let _port: String

	new val create(host: String, port: String) =>
		_host = host
		_port = port

	fun apply(wrap: TCPConnectionNotify iso): TCPConnectionNotify iso^ =>
		HttpProxyNotify(_host, _port, consume wrap)


primitive _HttpProxyStateDisconnected
primitive _HttpProxyStateConnected
primitive _HttpProxyStatePassThrough
type _HttpProxyState is ( _HttpProxyStateDisconnected | _HttpProxyStateConnected | _HttpProxyStatePassThrough )

class iso HttpProxyNotify is TCPConnectionNotify
	let _host: String
	let _service: String
	let _wrapped: TCPConnectionNotify ref
	var _state: _HttpProxyState = _HttpProxyStateDisconnected
	var _parser: (None | StreamingParser ) = None

	var _destination_host: ( None | String ) = None
	var _destination_service: ( None | String ) = None

	new iso create(host: String, service: String, wrapped: TCPConnectionNotify iso) =>
		_host = host
		_service = service
		_wrapped = consume wrapped

	fun ref proxy_via(host: String, service: String): (String, String) =>
		_destination_host = host
		_destination_service = service
		(_host, _service)

	fun ref connected(conn: TCPConnection ref) =>
		// _parser = StreamingParser({
		// 	(data: (Array[U8] iso))(c = conn) => _wrapped.received(c, consume data)
		// 	} ref)
		conn.write(
			"CONNECT " + _host + ":" + _service + " HTTP/1.1\r\n" +
			"Host: " + _host + ":" + _service + "\r\n" +
			// Authentication // UserAgent // etc //
			"\r\n"
		)
		_state = _HttpProxyStateConnected
		None

	fun ref received(
		conn: TCPConnection ref,
		data: Array[U8] iso,
		times: USize)
		: Bool
		=>
		match _state
		| _HttpProxyStateConnected =>
			let result = try (_parser as StreamingParser).apply(consume data) end
			match result
			| let response: Response val =>
				if response.response_code < 400 then // XXX better error conditions and handling.
					for b in response.body.values() do
						_wrapped.received(conn, recover iso b.clone() end, 0)
					end
					_state = _HttpProxyStatePassThrough
				else
					_wrapped.auth_failed(conn)
					conn.close()
				end
			end
		| _HttpProxyStatePassThrough =>
			_wrapped.received(conn, consume data, times)
		end
		true

	fun ref connecting(conn: TCPConnection ref, count: U32) =>
		_wrapped.connecting(conn, count)

	fun ref connect_failed(conn: TCPConnection ref) =>
		_wrapped.connect_failed(conn)

	fun ref auth_failed(conn: TCPConnection ref) =>
		_wrapped.auth_failed(conn)

	fun ref sent(conn: TCPConnection ref, data: ByteSeq): ByteSeq =>
		_wrapped.sent(conn, data)

	fun ref sentv(conn: TCPConnection ref, data: ByteSeqIter): ByteSeqIter =>
		_wrapped.sentv(conn, data)

	fun ref expect(conn: TCPConnection ref, qty: USize): USize =>
		_wrapped.expect(conn, qty)

	fun ref closed(conn: TCPConnection ref) =>
		_wrapped.closed(conn)

	fun ref throttled(conn: TCPConnection ref) =>
		_wrapped.throttled(conn)

	fun ref unthrottled(conn: TCPConnection ref) =>
		_wrapped.unthrottled(conn)
