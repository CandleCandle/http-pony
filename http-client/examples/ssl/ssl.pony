use "../../http-client"
use "../common"
use "net"
use "net/ssl"
use "cli"
use "files"

primitive CmdCert fun apply(): String => "cert"
primitive CmdCaFile fun apply(): String => "cafile"
type Cmd is ( CmdCert | CmdCaFile )
primitive Cmds fun apply(): Array[Cmd] val => [CmdCert; CmdCaFile]

actor Main
	new create(env: Env) =>
		let spec = try
				CommandSpec.leaf("simple", "",
					[
						OptionSpec.string(CmdCert(), "", None, "")
						OptionSpec.string(CmdCaFile())
					]
				)?
			else
				env.exitcode(-1)
				return
			end

		let cmd = match CommandParser(spec).parse(env.args, env.vars)
			| let c: Command => c
			| let help: CommandHelp =>
				help.print_help(env.out)
				env.exitcode(0)
				return
			| let err: SyntaxError =>
				env.out.print(err.string())
				env.exitcode(1)
				return
			end


		let auth = try
				TCPConnectAuth(env.root as AmbientAuth)
			else
				env.out.print("error at auth convertion")
				return
			end

		env.out.print("cert: " + cmd.option(CmdCert()).string())
		env.out.print("cafile: " + cmd.option(CmdCaFile()).string())

		let pem = try
				FilePath(env.root as AmbientAuth, cmd.option(CmdCaFile()).string())?
			else
				env.out.print("error at file path.")
				return
			end

		let ssl_context: SSLContext trn = recover trn SSLContext.create() end
		try
			ssl_context.>set_authority(pem, None)?
				.>set_client_verify(false)
		else
			env.out.print("error at authority; check that --cafile is set.")
			return
		end

		let req: Request trn = recover trn Request(URI.create("https", "localhost", "4577", "/foo")) end
		req.>with_header(HeaderAccept, "*/*")
			.>with_header(HeaderHost, "localhost")

		let c: HttpClient = SimpleHttpClient(
			auth,
			consume ssl_context,
			5_000_000_000,
			1_000_000_000
			)

		c.request(consume req).next[None](Dump~dump_response(env))

// vi: sw=4 sts=4 ts=4 noet
