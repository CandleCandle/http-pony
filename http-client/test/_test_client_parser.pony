use "ponytest"
use "../http-client"

primitive TestClientParser is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "parser / simple"
	fun apply(h: TestHelper) =>
		let undertest = IncrementalParser.create()
		var result: ( None | HttpResult ) = None
		result = undertest.apply((recover iso String().>append("HTTP/1.1 200 OK\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("HeaderOne: one\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("Content-Length: 1\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("q") end).iso_array())
		match result
		| None => h.fail("Expecting a HttpResult, got None")
		| let r: Response val =>
			h.assert_eq[U16](r.response_code, U16(200))
		else
			h.fail("other response.")
		end
end

object iso is UnitTest
	fun name(): String => "parser / 404"
	fun apply(h: TestHelper) =>
		let undertest = IncrementalParser.create()
		var result: ( None | HttpResult ) = None
		result = undertest.apply((recover iso String().>append("HTTP/1.1 404 Not Found\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("HeaderOne: one\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("Content-Length: 0\r\n") end).iso_array())
		h.assert_true(result is None)
		result = undertest.apply((recover iso String().>append("\r\n") end).iso_array())
		match result
		| None => h.fail("Expecting a HttpResult, got None")
		| let r: Response val =>
			h.assert_eq[U16](r.response_code, U16(404))
		end
end

]



// vi: sw=4 sts=4 ts=4 noet