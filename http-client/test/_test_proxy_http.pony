use "ponytest"
use "../http-client"

primitive TestProxyHttp is TestWrapped
	fun all_tests(): Array[UnitTest iso] =>
		[as UnitTest iso:

object iso is UnitTest
	fun name(): String => ""
	fun apply(h: TestHelper) =>
		let undertest = None
		h.assert_eq[String](undertest, None)
end

]


//actor Foo is TcpConnection
//	new create() => None