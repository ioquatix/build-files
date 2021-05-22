
require_relative "lib/build/files/version"

Gem::Specification.new do |spec|
	spec.name = "build-files"
	spec.version = Build::Files::VERSION
	
	spec.summary = "Abstractions for handling and mapping paths."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.0"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.4"
end
