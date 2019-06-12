use "../../http-client"


primitive Dump
	fun dump_response(env: Env, response: HttpResult) =>
		let result: U8 = match response // assign the result of this match to force the compiler to check that all potential HttpResult cases are matched.
		| let r: Response val =>
			env.out.print(r.response_code.string())
			for h in r.headers.values() do
				env.out.print(h._1 + " ==> " + h._2)
			end
			env.out.print("---")
			for a in r.body.values() do
				env.out.write(a)
			end
			env.out.print("")
			env.out.print("---")
			0
		| ErrorConnect =>
			env.out.print("error connect"); 1
		| ErrorTimeoutConnect =>
			env.out.print("error timeout connect"); 1
		| ErrorTimeoutIntraByte =>
			env.out.print("error timeout intra byte"); 1
		| ErrorSSLInit =>
			env.out.print("error ssl init"); 1
		| ErrorSSLHandshake =>
			env.out.print("error ssl handshake"); 1
		end

// vi: sw=4 sts=4 ts=4 noet
