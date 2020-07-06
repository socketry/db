
require_relative "lib/db/version"

Gem::Specification.new do |spec|
	spec.name = "db"
	spec.version = DB::VERSION
	
	spec.summary = "A low level database access gem."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/db"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "async-io"
	spec.add_dependency "async-pool"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.0"
end
