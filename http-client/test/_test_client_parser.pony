use "ponytest"
use "../http-client"

primitive Asserts
	fun tag assert_type[T](h: TestHelper, actual: Any) =>
		match actual
		| let t: T =>
			h.env.out.print("found expected type")
		else
			h.fail("unexpected type")
		end

actor TestClientParser is TestList
	new create(env: Env) =>
		PonyTest(env, this)

	new make() => None

	fun tag tests(test: PonyTest) =>
		let tests' = _all_tests()
		while tests'.size() > 0 do
			try test(tests'.pop()?) end
		end


	fun tag _all_tests(): Array[UnitTest iso] =>
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
		end

end

]



// vi: sw=4 sts=4 ts=4 noet