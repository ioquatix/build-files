source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
	
	gem "utopia-project"
end

group :test do
	gem 'rb-fsevent'
	gem 'rb-inotify'
end
