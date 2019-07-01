use "../../http-client"
use "../common"
use "net"
use "net/ssl"

actor Main
	new create(env: Env) =>

		let auth = try
				TCPConnectAuth(env.root as AmbientAuth)
			else
				env.out.print("error at auth convertion")
				return
			end

		// let proxy: Proxy = NoProxy
		let proxy: Proxy val = HttpProxy("some.http.proxy", "80")
		let c: HttpClient = SimpleHttpClient(auth, None, proxy, 5_000_000_000, 1_000_000_000)

		let req: Request trn = recover trn Request(URI.create("http", "http.only.host", "80", "/")) end
		req.>with_header("Accept", "*/*")
			.>with_header("Host", "neverssl.com")
		c.request(consume req).next[None](Dump~dump_response(env))

// vi: sw=4 sts=4 ts=4 noet
