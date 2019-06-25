use "../../http-client"
use "../common"
use "../../net-clone3"
use "../../net-clone3/ssl"
// use "net"

actor Main
	new create(env: Env) =>

		let auth = try
				TCPConnectAuth(env.root as AmbientAuth)
			else
				env.out.print("error at auth convertion")
				return
			end

		let c: HttpClient = SimpleHttpClient(auth, None, NoProxy, 5_000_000_000, 1_000_000_000)

		c.request(recover val Request(URI.create("http", "localhost", "4578", "/bar")) end)
			.next[None](Dump~dump_response(env))
		c.request(recover val Request(URI.create("http", "localhost", "4578", "/foo")) end)
			.next[None](Dump~dump_response(env))

		let req: Request trn = recover trn Request(URI.create("http", "localhost", "4578", "/blah")) end
		req.>with_method("PUT")
			.>with_header(HeaderUserAgent, "pony-http")
			.>with_header("RandomNoise", "blah")
		c.request(consume req).next[None](Dump~dump_response(env))


// vi: sw=4 sts=4 ts=4 noet
