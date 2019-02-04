
require_relative 'lib/build/files/version'

Gem::Specification.new do |spec|
	spec.name          = "build-files"
	spec.version       = Build::Files::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	# spec.description   = %q{}
	spec.summary       = %q{Build::Files is a set of idiomatic classes for dealing with paths and monitoring directories.}
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]
	
	spec.required_ruby_version = '>= 2.0'
	
	spec.add_dependency "rb-inotify"
	spec.add_dependency "rb-fsevent"
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rspec", "~> 3.4"
	spec.add_development_dependency "rake"
end
