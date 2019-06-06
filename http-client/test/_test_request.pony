use "ponytest"
use "../http-client"

primitive TestRequest is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "request / request-line / no query"
	fun apply(h: TestHelper) =>
		let undertest = Request.create(URI.create("http", "example.com", "80", "/"))
		h.assert_eq[String](undertest.request_line(), "GET / HTTP/1.1")
end

object iso is UnitTest
	fun name(): String => "request / request-line / query"
	fun apply(h: TestHelper) =>
		let undertest = Request.create(URI.create("http", "example.com", "80", "/", "foo=bar"))
		h.assert_eq[String](undertest.request_line(), "GET /?foo=bar HTTP/1.1")
end
]

// vi: sw=4 sts=4 ts=4 noet
