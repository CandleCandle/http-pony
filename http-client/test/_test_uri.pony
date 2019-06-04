use "ponytest"
use "../http-client"


actor TestURI is TestList
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
	fun name(): String => "uri / string / basic"
	fun apply(h: TestHelper) =>
		let undertest = URI.create("http", "example.com", "80", "/")
		h.assert_eq[String]("http://example.com:80/", undertest.string())
end

object iso is UnitTest
	fun name(): String => "uri / string / query"
	fun apply(h: TestHelper) =>
		let undertest = URI.create("http", "example.com", "80", "/", "foo=bar&zap=baz")
		h.assert_eq[String]("http://example.com:80/?foo=bar&zap=baz", undertest.string())
end

object iso is UnitTest
	fun name(): String => "uri / string / fragment"
	fun apply(h: TestHelper) =>
		let undertest = URI.create("http", "example.com", "80", "/", None, "frag")
		h.assert_eq[String]("http://example.com:80/#frag", undertest.string())
end

object iso is UnitTest
	fun name(): String => "uri / string / query+fragment"
	fun apply(h: TestHelper) =>
		let undertest = URI.create("http", "example.com", "80", "/", "foo=bar&zap=baz", "frag")
		h.assert_eq[String]("http://example.com:80/?foo=bar&zap=baz#frag", undertest.string())

end

]
// vi: sw=4 sts=4 ts=4 noet
