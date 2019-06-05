
class Response
	var response_code: U16
	let headers: Array[(String, String)] // Headers are ordered and can be repeated.
	let body: Array[Array[U8] val]

	new trn empty() =>
		response_code = 0
		headers = Array[(String, String)]
		body = Array[Array[U8] val]

	fun ref add_header(k: String, v: String) =>
		"""
		Add the k/v pair as a header. both k and v should have no trailing or leading whitespace
		"""
		headers.push((k, v))

	fun ref first_header(k': Header val): String ? =>
		"""
		returns the value of the first example of the specified header. Will not error if `has_header` has returned `true`
		"""
		for (k, v) in headers.values() do
			if k == k'() then
				return v
			end
		end
		error

	fun box has_header(k': Header val): Bool =>
		"""
		Check if the response contains the specified header.
		"""
		for (k, v) in headers.values() do
			if k == k'() then
				return true
			end
		end
		false

	fun ref add_body(data: Array[U8] val) =>
		body.push(data)

	fun body_as_str(): String =>
		let result = recover trn String end
		for a in body.values() do
			result.append(a)
		end
		result

	fun body_size(): USize =>
		var result: USize = 0
		for a in body.values() do
			result = result + a.size()
		end
		result
