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
require 'build/files/paths'
require 'build/files/glob'

module Build::Files::PathSpec
	include Build::Files
	
	describe Build::Files::Path do
		let(:path) {Path.new("/foo/bar/baz", "/foo")}
		
		it "should convert to string" do
			# The to_str method should return the full path (i.e. the same as to_s):
			expect(path.to_s).to be == path.to_str
			
			# Check the equality operator:
			expect(path).to be == path.dup
			
			# The length should be reported correctly:
			expect(path.length).to be == path.to_s.length
			
			# Check the return types:
			expect(path).to be_kind_of Path
			expect(path.root).to be_kind_of String
			expect(path.relative_path).to be_kind_of String
		end
		
		it "should consist of parts" do
			expect(path.parts).to be == ["", "foo", "bar", "baz"]
			
			expect(path.root).to be == "/foo"
			
			expect(path.relative_path).to be == "bar/baz"
			
			expect(path.relative_parts).to be == ["bar", "baz"]
		end
		
		it "should have a new extension" do
			renamed_path = path.with(root: '/tmp', extension: '.txt')
			
			expect(renamed_path.root).to be == '/tmp'
			
			expect(renamed_path.relative_path).to be == 'bar/baz.txt'
			
			object_path = path + ".o"
		
			expect(object_path.root).to be == "/foo"
			expect(object_path.relative_path).to be == "bar/baz.o"
		end
	end
	
	describe Build::Files::Paths do
		let(:path) {Path.new("/foo/bar/baz", "/foo")}
		
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
		
		it "can be used as key in hash" do
			cache = {}
			
			cache[Paths.new(path)] = true
			
			expect(cache).to include(Paths.new(path))
		end
	end
end
