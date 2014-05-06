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

require 'minitest/autorun'

require 'build/files'

class TestFiles < MiniTest::Test
	include Build::Files
	
	def test_inclusion
		# Glob all test files:
		glob = Glob.new(__dir__, "*.rb")
		
		assert glob.count > 0
		
		# Should include this file:
		assert_includes glob, __FILE__
		
		# Glob should intersect self:
		assert glob.intersects?(glob)
	end
	
	def test_composites
		lib = File.join(__dir__, "../lib")
		
		test_glob = Glob.new(__dir__, "*.rb")
		lib_glob = Glob.new(lib, "*.rb")
		
		both = test_glob + lib_glob
		
		# List#roots is the generic accessor for Lists
		assert both.roots.include? test_glob.root
		
		# The composite should include both:
		assert both.include?(__FILE__)
	end
	
	def test_roots
		test_glob = Glob.new(__dir__, "*.rb")
		
		assert_kind_of Path, test_glob.first
		
		assert_equal __dir__, test_glob.first.root
	end
	
	def test_renaming
		glob = Glob.new(__dir__, "*.rb")
		
		paths = glob.map {|path| path + ".txt"}
		
		assert_equal(paths.first, glob.first + ".txt")
	end
	
	def test_none
		assert_equal 0, NONE.count
	end
end
