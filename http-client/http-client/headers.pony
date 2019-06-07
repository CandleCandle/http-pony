
trait Header
	fun apply(): String val

primitive HeaderContentLength is Header
	fun apply(): String val => "Content-Length"
	fun parse(value: String): USize ? => value.usize()?

primitive HeaderHost is Header fun apply(): String val => "Host"
primitive HeaderUserAgent is Header fun apply(): String val => "User-Agent"
primitive HeaderConnection is Header fun apply(): String val => "Connection"
primitive HeaderSetCookie is Header fun apply(): String val => "Set-Cookie"
primitive HeaderAccept is Header fun apply(): String val => "Accept"
