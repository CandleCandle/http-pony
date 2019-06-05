
trait Header
	fun apply(): String val

primitive HeaderContentLength is Header
	fun apply(): String val => "Content-Length"
	fun parse(value: String): USize ? => value.usize()?
