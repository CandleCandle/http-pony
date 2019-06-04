use "ponytest"
use "../http-client"

actor Main is TestList
	new create(env: Env) =>
		PonyTest(env, this)
	new make() => None
	fun tag tests(test: PonyTest) =>
//		TestSimpleClient.make().tests(test)
		TestURI.make().tests(test)
		TestClientParser.make().tests(test)
		TestResponse.make().tests(test)



// vi: sw=4 sts=4 ts=4 noet