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

require 'build/files/glob'

RSpec.describe Build::Files::Glob do
	let(:path) {Build::Files::Path.new(__dir__)}
	
	it "can glob paths" do
		paths = path.glob("*.rb")
		
		expect(paths.count).to be >= 1
	end
	
	it "can be used as key in hash" do
		cache = {}
		
		cache[path.glob("*.rb")] = true
		
		expect(cache).to be_include(path.glob("*.rb"))
	end
	
	it "should print nice string represenation" do
		glob = Build::Files::Glob.new(".", "*.rb")
		
		expect("#{glob}").to be == '<Glob "."/"*.rb">'
	end
	
	context 'with dotfiles' do
		it "should list files starting with dot" do
			paths = path.glob("glob_spec/dotfiles/**/*")
			
			expect(paths.count).to be == 1
		end
	end
end
