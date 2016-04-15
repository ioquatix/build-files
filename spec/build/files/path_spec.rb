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
require 'build/files/path'

require 'pathname'

module Build::Files::PathSpec
	include Build::Files
	
	describe Build::Files::Path do
		it "should expand the path" do
			expect(Build::Files::Path.expand("foo", "/bar")).to be == "/bar/foo"
		end
	end
	
	describe Build::Files::Path.new("/test") do
		it "should start_with? full path" do
			expect(subject).to be_start_with '/test'
		end
		
		it "should start_with? partial pattern" do
			expect(subject).to be_start_with '/te'
		end
	end
	
	describe Build::Files::Path.new("/foo/bar/baz", "/foo") do
		it "should be inspectable" do
			expect(subject.inspect).to be_include subject.root.to_s
			expect(subject.inspect).to be_include subject.relative_path.to_s
		end
		
		it "should convert to path" do
			pathname = Pathname("/foo/bar/baz")
			
			expect(Path[pathname]).to be == subject
			expect(Path["/foo/bar/baz"]).to be == subject
		end
		
		it "should be equal" do
			expect(subject).to be_eql subject
			expect(subject).to be == subject
			
			different_root_path = Path.join("/foo/bar", "baz")
			expect(subject).to_not be_eql different_root_path
			expect(subject).to be == different_root_path
		end
		
		it "should convert to string" do
			expect(subject.to_s).to be == "/foo/bar/baz"
			
			# The to_str method should return the full path (i.e. the same as to_s):
			expect(subject.to_s).to be == subject.to_str
			
			# Check the equality operator:
			expect(subject).to be == subject.dup
			
			# The length should be reported correctly:
			expect(subject.length).to be == subject.to_s.length
			
			# Check the return types:
			expect(subject).to be_kind_of Path
			expect(subject.root).to be_kind_of String
			expect(subject.relative_path).to be_kind_of String
		end
		
		it "should consist of parts" do
			expect(subject.parts).to be == ["", "foo", "bar", "baz"]
			
			expect(subject.root).to be == "/foo"
			
			expect(subject.relative_path).to be == "bar/baz"
			
			expect(subject.relative_parts).to be == ["bar", "baz"]
		end
		
		it "should have a new extension" do
			renamed_path = subject.with(root: '/tmp', extension: '.txt')
			
			expect(renamed_path.root).to be == '/tmp'
			
			expect(renamed_path.relative_path).to be == 'bar/baz.txt'
			
			object_path = subject.append(".o")
		
			expect(object_path.root).to be == "/foo"
			expect(object_path.relative_path).to be == "bar/baz.o"
		end
		
		it "should give the shortest path for outer paths" do
			input = Path.new("/a/b/c/file.cpp")
			output = Path.new("/a/b/c/d/e/")
			
			expect(input.root).to be == "/a/b/c"
			expect(output.root).to be == "/a/b/c/d/e"
			
			short = input.shortest_path(output)
			
			expect(short).to be == "../../file.cpp"
			
			expect(File.expand_path(short, output)).to be == input
		end
		
		it "should give the shortest path for inner paths" do
			input = Path.new("/a/b/c/file.cpp")
			output = Path.new("/a/")
			
			expect(input.root).to be == "/a/b/c"
			expect(output.root).to be == "/a"
			
			short = input.shortest_path(output)
			
			expect(short).to be == "b/c/file.cpp"
			
			expect(File.expand_path(short, output)).to be == input
		end
		
		it "should append a path" do
			subject = Path.new("/a/b/c")
			
			expect(subject + "d/e/f").to be == "/a/b/c/d/e/f"
		end
		
		it "should give a list of components" do
			expect(Path.components(subject)).to be == ["", "foo", "bar", "baz"]
			expect(Path.components(subject.to_s)).to be == ["", "foo", "bar", "baz"]
		end
		
		it "should give a basename" do
			expect(subject.basename).to be == "baz"
		end
		
		it "should have a new root" do
			rerooted_path = subject / "cat"
			
			expect(rerooted_path.root).to be == "/foo/bar/baz"
			expect(rerooted_path.relative_path).to be == "cat"
		end
		
		it "should give correct modes for reading" do
			expect(subject.for_reading).to be == [subject.to_s, File::RDONLY]
		end
		
		it "should give correct modes for writing" do
			expect(subject.for_writing).to be == [subject.to_s, File::CREAT|File::TRUNC|File::WRONLY]
		end
		
		it "should give correct modes for appending" do
			expect(subject.for_appending).to be == [subject.to_s, File::CREAT|File::APPEND|File::WRONLY]
		end
	end
end
