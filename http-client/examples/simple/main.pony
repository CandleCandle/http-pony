use "../../http-client"

actor Main
	new create(env: Env) =>
		
		try
			let c: HttpClient = SimpleHttpClient(env.root as AmbientAuth, 5_000_000_000, 1_000_000_000)

			let t: Main tag = recover tag this end
			c.request(Request(URI.create("http", "localhost", "4578", "/bar"))).next[None](t~dump_response(env))
			c.request(Request(URI.create("http", "localhost", "4578", "/foo"))).next[None](t~dump_response(env))
		else
			env.out.print("error.")
		end

	fun tag dump_response(env: Env, response: HttpResult) =>
		match response
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
		| ErrorConnect =>
			env.out.print("error connect")
		| ErrorTimeoutConnect =>
			env.out.print("error timeout connect")
		| ErrorTimeoutIntraByte =>
			env.out.print("error timeout intra byte")
		end

// vi: sw=4 sts=4 ts=4 noet
