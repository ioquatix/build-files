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
require 'build/files/path/filesystem'

require 'pathname'

module Build::Files::FilesystemSpec
	include Build::Files
	
	describe Build::Files::Path do
		let(:root) {Path.new(__dir__)}
		let(:path) {root + "filesystem_spec"}
		
		after(:each) do
			path.delete
		end
		
		it "should open file for writing" do
			path.write("Hello World")
			
			expect(File).to be_exist(path)
			expect(path.read).to be == "Hello World"
			
			expect(path).to be_exist
			expect(path.directory?).to be == false
			
			expect(path.modified_time.to_f).to be_within(5.0).of(Time.now.to_f)
		end
		
		it "should make a directory" do
			path.create
			
			expect(path.directory?).to be == true
		end
	end
end
