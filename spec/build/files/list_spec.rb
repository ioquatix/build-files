# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'build/files'
require 'build/files/list'
require 'build/files/glob'

module Build::Files::ListSpec
	include Build::Files
	
	describe Build::Files::Paths do
		let(:path) {Path.new("/foo/bar/baz", "/foo")}
		
		it "should be inspectable" do
			paths = Paths.new(path)
			
			expect(paths.inspect).to be_include path.inspect
		end
		
		it "should be possible to convert to paths" do
			paths = Paths.new(path)
			
			expect(paths.to_paths).to be paths
		end
		
		it "should be count number of paths" do
			paths = Paths.new(path)
			
			expect(paths.count).to be == 1
		end
		
		it "should coerce array to paths" do
			paths = Paths.coerce([path])
			
			expect(paths).to be_kind_of Paths
			expect(paths.count).to be == 1
			expect(paths).to be_include path
			
			same_paths = Paths.coerce(paths)
			expect(same_paths).to be paths
		end
		
		it "can add two lists of paths together" do
			paths_a = Paths.new(path)
			paths_b = Paths.new(Path.join('/foo/bar', 'alice'))
			
			paths = paths_a + paths_b
			
			expect(paths.count).to be 2
			expect(paths).to be_include path
			expect(paths).to be_kind_of Composite
			
			# Composite equality
			expect(paths).to be_eql paths
			expect(paths).to_not be_eql paths_a
		end
		
		it "maps paths with a new extension" do
			paths = Paths.new([
				Path.join('/foo/bar', 'alice'),
				Path.join('/foo/bar', 'bob'),
				Path.join('/foo/bar', 'charles'),
				path
			])
			
			expect(paths).to include(path)
			
			expect(paths).to be_intersects(paths)
			expect(paths).to_not be_intersects(Paths::NONE)
			
			mapped_paths = paths.map {|path| path + ".o"}
			
			expect(mapped_paths).to be_kind_of(Paths)
			expect(mapped_paths.roots).to be == paths.roots
		end
		
		it "globs multiple files" do
			glob = Glob.new(__dir__, '*.rb')
			
			expect(glob.count).to be > 1
			
			mapped_paths = glob.map {|path| path + ".txt"}
			
			expect(glob.roots).to be == mapped_paths.roots
		end
		
		it "should intersect one file in the glob" do
			# Glob all test files:
			glob = Glob.new(__dir__, "*.rb")
		
			expect(glob.count).to be > 0
		
			# Should include this file:
			expect(glob).to include(__FILE__)
		
			# Glob should intersect self:
			expect(glob).to be_intersects(glob)
		end
		
		it "should include composites" do
			lib = File.join(__dir__, "../lib")
		
			test_glob = Glob.new(__dir__, "*.rb")
			lib_glob = Glob.new(lib, "*.rb")
		
			both = test_glob + lib_glob
		
			# List#roots is the generic accessor for Lists
			expect(both.roots).to include test_glob.root
		
			# The composite should include both:
			expect(both).to include(__FILE__)
		end
		
		it "should have path with correct root" do
			test_glob = Glob.new(__dir__, "*.rb")
			
			expect(test_glob.first).to be_kind_of Path
			
			expect(test_glob.first.root).to be == __dir__
		end
		
		it "maps paths with new extension" do
			glob = Glob.new(__dir__, "*.rb")
			
			paths = glob.map {|path| path.append ".txt"}
			
			expect(paths.first).to be == (glob.first.append ".txt")
			expect(paths.first.to_s).to be_end_with ".rb.txt"
		end
		
		it "should map paths using with" do
			glob = Glob.new(__dir__, "*.rb")
			
			paths = glob.with extension: ".txt"
			path = paths.first
			
			expect(path).to be_kind_of Array
			
			expect(path[0]).to be == glob.first
			expect(path[1]).to be == glob.first.append(".txt")
		end
		
		it "should define an empty set of files" do
			expect(Paths::NONE).to be_kind_of List
			
			expect(Paths::NONE.count).to be 0
		end
		
		it "can be used as key in hash" do
			cache = {}
			
			cache[Paths.new(path)] = true
			
			expect(cache).to be_include(Paths.new(path))
		end
		
		it "can be constructed from a list of relative paths" do
			paths = Paths.directory('/foo', ['bar', 'baz', 'bob'])
			
			expect(paths.count).to be 3
			expect(paths).to be_include Path.new('/foo/bar')
		end
	end
end
