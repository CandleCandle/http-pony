use "ponytest"
use "../http-client"


actor TestResponse is TestList
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
	fun name(): String => "response / header / has_header / single"
	fun apply(h: TestHelper) =>
		let undertest = Response.empty()
		undertest.add_header("Content-Length", "42")
		h.assert_eq[Bool](undertest.has_header(HeaderContentLength), true)
end

object iso is UnitTest
	fun name(): String => "response / header / has_header / duplicate"
	fun apply(h: TestHelper) =>
		let undertest = Response.empty()
		undertest.add_header("Content-Length", "42")
		undertest.add_header("Content-Length", "92")
		h.assert_eq[Bool](undertest.has_header(HeaderContentLength), true)
end

object iso is UnitTest
	fun name(): String => "response / header / has_header / missing"
	fun apply(h: TestHelper) =>
		let undertest = Response.empty()
		undertest.add_header("Other", "zap")
		h.assert_eq[Bool](undertest.has_header(HeaderContentLength), false)
end

object iso is UnitTest
	fun name(): String => "response / header / first_header / single"
	fun apply(h: TestHelper) =>
		try
			let undertest = Response.empty()
			undertest.add_header("Content-Length", "42")
			h.assert_eq[String](undertest.first_header(HeaderContentLength)?, "42")
		else
			h.fail("error raised.")
		end
end

object iso is UnitTest
	fun name(): String => "response / header / first_header / duplicate"
	fun apply(h: TestHelper) =>
		try
			let undertest = Response.empty()
			undertest.add_header("Content-Length", "42")
			undertest.add_header("Other", "zap")
			undertest.add_header("Content-Length", "92")
			h.assert_eq[String](undertest.first_header(HeaderContentLength)?, "42")
		else
			h.fail("error raised.")
		end
end


]
// vi: sw=4 sts=4 ts=4 noet
