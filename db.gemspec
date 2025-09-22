# frozen_string_literal: true

require_relative "lib/db/version"

Gem::Specification.new do |spec|
	spec.name = "db"
	spec.version = DB::VERSION
	
	spec.summary = "A low level database access gem."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/db"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/db/",
		"funding_uri" => "https://github.com/sponsors/ioquatix",
		"source_code_uri" => "https://github.com/socketry/db.git",
	}
	
	spec.files = Dir.glob(["{context,lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.2"
	
	spec.add_dependency "async-pool"
end
