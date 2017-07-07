# Copyright, 2014, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'build/files/directory'

module Build::Files::DirectorySpec
	include Build::Files
	
	describe Build::Files::Directory do
		let(:path) {Path.new("/foo/bar/baz", "/foo")}
		let(:directory) {Directory.new(path)}
		
		it "can be constructed using join" do
			joined_directory = Directory.join('/foo', 'bar/baz')
			
			expect(joined_directory).to be == directory
		end
		
		it "has a root and path component" do
			expect(directory.root).to be == path
			expect(directory.to_path).to be == path
			
			expect(directory.roots).to be_include(path)
		end
		
		it "can be converted into a string" do
			expect(directory.to_str).to be == path.to_str
		end
		
		it "can be used as a key" do
			hash = {directory => true}
			
			expect(hash).to be_include directory
		end
		
		it "includes subpaths" do
			expect(directory).to be_include "/foo/bar/baz/bob/dole"
		end
		
		it "can be compared" do
			other_directory = Directory.new(path + 'dole')
			
			expect(directory).to be_eql directory
			expect(directory).to_not be_eql other_directory
		end
		
		it "can be rebased" do
			rebased_directory = directory.rebase("/fu")
			
			expect(rebased_directory.root).to be == '/fu/bar/baz'
		end
		
		context Directory.join(__dir__, "directory_spec") do
			it "can list dot files" do
				expect(subject).to include(subject.root + '.dot_file.yaml')
			end
			
			it "can list normal files" do
				expect(subject).to include(subject.root + 'normal_file.txt')
			end
		end
	end
end
