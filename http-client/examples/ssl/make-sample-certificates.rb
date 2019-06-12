require 'openssl'

class BasicCertificate
	attr_reader :cert, :key, :name
	def initialize(name, distinguished_name)
		@name = name
		@key = OpenSSL::PKey::RSA.new(1024)

		@cert = OpenSSL::X509::Certificate.new
		@cert.subject = OpenSSL::X509::Name.parse(distinguished_name)
		@cert.not_before = Time.now - (10 * 24 * 60 * 60)
		@cert.not_after = Time.now + (10 * 24 * 60 * 60)
		@cert.public_key = @key.public_key
		@cert.serial = Random.rand(0...2**16)
		@cert.version = 2
	end

	def cert_to_pem
		@cert.to_pem
	end
	def key_to_pem
		@key.to_pem
	end
	def root?() false end
end

class RootCertificate < BasicCertificate
	def initialize(name, distinguished_name)
		super(name, distinguished_name)
		@cert.issuer = @cert.subject
		extensions = OpenSSL::X509::ExtensionFactory.new
		extensions.subject_certificate = @cert
		extensions.issuer_certificate = @cert
		@cert.extensions = [
				extensions.create_extension("basicConstraints","CA:TRUE", true),
				extensions.create_extension("subjectKeyIdentifier", "hash"),
		]
		@cert.add_extension extensions.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")

		@cert.sign(@key, OpenSSL::Digest::SHA256.new)
	end
	def root?() true end
end

class SubCertificate < BasicCertificate
	attr_reader :issuer
	def initialize(name, distinguished_name, issuer, san = [])
		super(name, distinguished_name)
		@issuer = issuer
		@cert.issuer = issuer.cert.subject
		extensions = OpenSSL::X509::ExtensionFactory.new
		extensions.subject_certificate = @cert
		extensions.issuer_certificate = issuer.cert
		@cert.extensions = [
				extensions.create_extension("basicConstraints","CA:FALSE", true),
				extensions.create_extension("subjectAltName", san.flat_map {|k,a| a.map {|d| "#{k}: #{d}"} }.join(','))
		]

		@cert.sign(issuer.key, OpenSSL::Digest::SHA256.new)
	end
end


root = RootCertificate.new("root", "/CN=root")
service = SubCertificate.new("service", "/CN=localhost", root, {"DNS": ["localhost"], "IP": ["127.0.0.1"]})

File.open("root.pem", 'w') { |f| f.write(root.cert_to_pem()) }
File.open("root.key", 'w') { |f| f.write(root.key_to_pem()) }
File.open("service.pem", 'w') { |f| f.write(service.cert_to_pem()) }
File.open("service.key", 'w') { |f| f.write(service.key_to_pem()) }


# vi: sw=4 ts=4 sts=4 noet
