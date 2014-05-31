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

module Build::Files::FilesSpec
	include Build::Files
	
	describe Build::Files do
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
			
			paths = glob.map {|path| path + ".txt"}
			
			expect(paths.first).to be == (glob.first + ".txt")
		end
		
		it "should define an empty set of files" do
			expect(Paths::NONE).to be_kind_of List
			
			expect(Paths::NONE.count).to be 0
		end
	end
end
