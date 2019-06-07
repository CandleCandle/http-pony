
primitive SchemeHttp fun apply(): String val => "http"
primitive SchemeHttps fun apply(): String val => "https"
type Scheme is ( SchemeHttp | SchemeHttps )
primitive Schemes fun apply(): Array[Scheme] val => [SchemeHttp; SchemeHttps]

class val URI is Stringable
	let scheme: ( Scheme | String )
	// authentication
	let host: String
	let port: String
	let path: String // never 'None', minimum is "/"
	let query: (String | None)
	let fragment: (String | None)

	new val create(scheme': ( Scheme | String ), host': String, port': String, path': String, query': (String | None) = None, fragment': (String | None) = None) =>
		scheme = scheme'
		host = host'
		port = port'
		path = path'
		query = query'
		fragment = fragment'

	// TODO new parse(uri: String) => ...

	fun string(): String iso^ =>
		recover iso 
			let s = String()
			s.>append(match scheme | let sc: String => sc | let sc: Scheme => sc() end )
				.>append("://")
				.>append(host)
				.>append(":")
				.>append(port)
				.>append(path)
			match query
			| let q: String => s.>append("?").append(q)
			end
			match fragment
			| let f: String => s.>append("#").append(f)
			end
			s
		end
