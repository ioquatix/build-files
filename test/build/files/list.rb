# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require "build/files"
require "build/files/list"
require "build/files/glob"

include Build::Files

describe Build::Files::Paths do
	let(:path) {Path.new("/foo/bar/baz", "/foo")}
	
	it "should be inspectable" do
		paths = Paths.new(path)
		
		expect(paths.inspect).to be(:include?, path.inspect)
	end
	
	it "should be possible to convert to paths" do
		paths = Paths.new(path)
		
		expect(paths.to_paths).to be == paths
	end
	
	it "should be count number of paths" do
		paths = Paths.new(path)
		
		expect(paths.count).to be == 1
	end
	
	it "should coerce array to paths" do
		paths = Paths.coerce([path])
		
		expect(paths).to be_a Paths
		expect(paths.count).to be == 1
		expect(paths).to be(:include?, path)
		
		same_paths = Paths.coerce(paths)
		expect(same_paths).to be == paths
	end
	
	it "can add two lists of paths together" do
		paths_a = Paths.new(path)
		paths_b = Paths.new(Path.join("/foo/bar", "alice"))
		
		paths = paths_a + paths_b
		
		expect(paths).not.to be(:empty?)
		expect(paths.count).to be == 2
		expect(paths).to be(:include?, path)
		expect(paths).to be_a Composite
		
		# Composite equality
		expect(paths).to be(:eql?, paths)
		expect(paths).not.to be(:eql?, paths_a)
	end
	
	it "can subtract two lists of paths" do
		paths_a = Paths.new(path)
		paths_b = Paths.new(path)
		
		paths = paths_a - paths_b
		expect(paths).to be(:empty?)
	end
	
	it "maps paths with a new extension" do
		paths = Paths.new([
			Path.join("/foo/bar", "alice"),
			Path.join("/foo/bar", "bob"),
			Path.join("/foo/bar", "charles"),
			path
		])
		
		expect(paths).to be(:include?, path)
		
		expect(paths).to be(:intersects?, paths)
		expect(paths).not.to be(:intersects?, Paths::NONE)
		
		mapped_paths = paths.map {|path| path + ".o"}
		
		expect(mapped_paths).to be_a(Paths)
		expect(mapped_paths.roots).to be == paths.roots
	end
	
	it "globs multiple files" do
		glob = Glob.new(__dir__, "*.rb")
		
		expect(glob.count).to be > 1
		
		mapped_paths = glob.map {|path| path + ".txt"}
		
		expect(glob.roots).to be == mapped_paths.roots
	end
	
	it "should intersect one file in the glob" do
		# Glob all test files:
		glob = Glob.new(__dir__, "*.rb")
	
		expect(glob.count).to be > 0
	
		# Should include this file:
		expect(glob).to be(:include?, __FILE__)
	
		# Glob should intersect self:
		expect(glob).to be(:intersects?, glob)
	end
	
	it "should include composites" do
		lib = File.join(__dir__, "../lib")
	
		test_glob = Glob.new(__dir__, "*.rb")
		lib_glob = Glob.new(lib, "*.rb")
	
		both = test_glob + lib_glob
	
		# List#roots is the generic accessor for Lists
		expect(both.roots).to be(:include?, test_glob.root)
	
		# The composite should include both:
		expect(both).to be(:include?, __FILE__)
	end
	
	it "should have path with correct root" do
		test_glob = Glob.new(__dir__, "*.rb")
		
		expect(test_glob.first).to be_a Path
		
		expect(test_glob.first.root).to be == __dir__
	end
	
	it "maps paths with new extension" do
		glob = Glob.new(__dir__, "*.rb")
		
		paths = glob.map {|path| path.append ".txt"}
		
		expect(paths.first).to be == (glob.first.append ".txt")
		expect(paths.first.to_s).to be(:end_with?, ".rb.txt")
	end
	
	it "should map paths using with" do
		glob = Glob.new(__dir__, "*.rb")
		
		paths = glob.with extension: ".txt"
		path = paths.first
		
		expect(path).to be_a Array
		
		expect(path[0]).to be == glob.first
		expect(path[1]).to be == glob.first.append(".txt")
	end
	
	it "should define an empty set of files" do
		expect(Paths::NONE).to be_a List
		
		expect(Paths::NONE.count).to be == 0
	end
	
	it "can be used as key in hash" do
		cache = {}
		
		cache[Paths.new(path)] = true
		
		expect(cache).to be(:include?, Paths.new(path))
	end
	
	it "can be constructed from a list of relative paths" do
		paths = Paths.directory("/foo", ["bar", "baz", "bob"])
		
		expect(paths.count).to be == 3
		expect(paths).to be(:include?, Path.new("/foo/bar"))
	end
end
