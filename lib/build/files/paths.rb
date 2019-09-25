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

require_relative 'list'

module Build
	module Files
		class Paths < List
			def initialize(list, roots = nil)
				@list = Array(list).freeze
				@roots = roots
			end
			
			attr :list
			
			# The list of roots for a given list of immutable files is also immutable, so we cache it for performance:
			def roots
				@roots ||= super
			end
			
			def count
				@list.count
			end
			
			def each
				return to_enum(:each) unless block_given?
				
				@list.each{|path| yield path}
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @list.eql?(other.list)
			end
		
			def hash
				@list.hash
			end
			
			def to_paths
				self
			end
			
			def inspect
				"<Paths #{@list.inspect}>"
			end
			
			def self.directory(root, relative_paths)
				paths = relative_paths.collect do |path|
					Path.join(root, path)
				end
				
				self.new(paths, [root])
			end
		end
		
		class Path
			def list(*relative_paths)
				Paths.directory(self, relative_paths)
			end
		end
	end
end
