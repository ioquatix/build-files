# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2023, by Samuel Williams.

require 'build/files/glob'

describe Build::Files::Glob do
	let(:path) {Build::Files::Path.new(__dir__)}
	
	it "can glob paths" do
		paths = path.glob("*.rb")
		
		expect(paths.count).to be >= 1
	end
	
	it "can be used as key in hash" do
		cache = {}
		
		cache[path.glob("*.rb")] = true
		
		expect(cache).to be(:include?, path.glob("*.rb"))
	end
	
	it "should print nice string represenation" do
		glob = Build::Files::Glob.new(".", "*.rb")
		
		expect("#{glob}").to be == '<Glob "."/"*.rb">'
	end
	
	with 'dotfiles' do
		it "should list files starting with dot" do
			paths = path.glob(".glob/dotfiles/**/*")
			
			expect(paths.count).to be == 1
		end
	end
end
