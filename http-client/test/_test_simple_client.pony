use "ponytest"
use "../http-client"
use "net"

primitive TestSimpleClient is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => "http-client / Simple"
	fun apply(h: TestHelper) =>
		try
			let undertest = SimpleHttpClient(TCPConnectAuth(h.env.root as AmbientAuth), None, 10_000_000_000, 1_000_000_000)
			h.long_test(1_000_000_000)
			undertest.request(recover val Request.create(URI.create("http", "example.com", "80", "/", None, None)) end)
				.next[None]({(r: HttpResult) =>
					match r
					| let rr: Response val => h.complete(true)
					else
						h.complete(false)
					end
				})
		else
			h.fail()
		end

end

]
// vi: sw=4 sts=4 ts=4 noet
