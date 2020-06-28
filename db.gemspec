
require_relative "lib/db/version"

Gem::Specification.new do |spec|
	spec.name = "db"
	spec.version = DB::VERSION
	spec.authors = ["Samuel Williams"]
	spec.email = ["samuel.williams@oriontransfer.co.nz"]
	
	spec.summary = "A low level database access gem."
	spec.homepage = "https://github.com/socketry/db"
	
	spec.files = Dir.chdir(__dir__) do
		`git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/})}
	end
	
	spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]
	
	spec.add_dependency "async-io"
	spec.add_dependency "async-pool"
	
	spec.add_development_dependency "bake"
	spec.add_development_dependency "bake-bundler"
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "bundler", "~> 2.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
