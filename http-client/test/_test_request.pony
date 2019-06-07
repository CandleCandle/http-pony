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

object iso is UnitTest
	fun name(): String => "request / request-line / method"
	fun apply(h: TestHelper) =>
		let undertest = Request.create(URI.create("http", "example.com", "80", "/", "foo=bar")).>with_method("PUT")
		h.assert_eq[String](undertest.request_line(), "PUT /?foo=bar HTTP/1.1")
end

object iso is UnitTest
	fun name(): String => "request / to_request / no headers"
	fun apply(h: TestHelper) =>
		let undertest = Request.create(URI.create("http", "example.com", "80", "/", "foo=bar"))
			.>with_method("PUT")
		h.assert_eq[String](undertest.to_request(), "PUT /?foo=bar HTTP/1.1\r\n\r\n")
end

object iso is UnitTest
	fun name(): String => "request / to_request / one header"
	fun apply(h: TestHelper) =>
		let undertest = Request.create(URI.create("http", "example.com", "80", "/", "foo=bar"))
			.>with_method("PUT")
			.>with_header(HeaderUserAgent, "pony-http")
		h.assert_eq[String](undertest.to_request(), "PUT /?foo=bar HTTP/1.1\r\nUser-Agent: pony-http\r\n\r\n")
end

object iso is UnitTest
	fun name(): String => "request / to_request / multiple header"
	fun apply(h: TestHelper) =>
		let undertest = Request.create(URI.create("http", "example.com", "80", "/", "foo=bar"))
			.>with_method("PUT")
			.>with_header(HeaderUserAgent, "pony-http")
			.>with_header(HeaderHost, "example.com")
			.>with_header(HeaderAccept, "*/*")
		h.assert_eq[String](undertest.to_request(), 
				"PUT /?foo=bar HTTP/1.1\r\n"
				+"User-Agent: pony-http\r\n"
				+"Host: example.com\r\n"
				+"Accept: */*\r\n"
				+"\r\n")
end

]

// vi: sw=4 sts=4 ts=4 noet
