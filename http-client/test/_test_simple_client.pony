use "ponytest"
use "../http-client"


actor TestSimpleClient is TestList
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
	fun name(): String => "http-client / Simple"
	fun apply(h: TestHelper) =>
		try
			let undertest = SimpleHttpClient(h.env.root as AmbientAuth, 10_000_000_000, 1_000_000_000)
			h.long_test(1_000_000_000)
			undertest.request(Request.create(URI.create("http", "example.com", "80", "/", None, None)))
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
