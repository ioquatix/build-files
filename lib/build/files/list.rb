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

require_relative 'path'

module Build
	module Files
		# A list of paths, where #each yields instances of Path.
		class List
			include Enumerable
			
			def roots
				collect{|path| path.root}.sort.uniq
			end
			
			# Create a composite list out of two other lists:
			def +(list)
				Composite.new([self, list])
			end
			
			# This isn't very efficient, but it IS generic.
			def ==(other)
				if self.class == other.class
					self.eql?(other)
				elsif other.kind_of? self.class
					self.to_a.sort == other.to_a.sort
				else
					super
				end
			end
			
			# Does this list of files include the path of any other?
			def intersects? other
				other.any?{|path| include?(path)}
			end
			
			def with(**args)
				return to_enum(:with, **args) unless block_given?
				
				paths = []
				
				each do |path|
					updated_path = path.with(args)
					
					yield path, updated_path
					
					paths << updated_path
				end
				
				return Paths.new(paths)
			end
			
			def rebase(root)
				Paths.new(self.collect{|path| path.rebase(root)}, [root])
			end
			
			def to_paths
				Paths.new(each.to_a)
			end
			
			def map
				Paths.new(super)
			end
			
			def self.coerce(arg)
				if arg.kind_of? self
					arg
				else
					Paths.new(arg)
				end
			end
		end
		
		class Composite < List
			def initialize(files, roots = nil)
				@files = []
				
				files.each do |list|
					if list.kind_of? Composite
						@files += list.files
					elsif List.kind_of? List
						@files << list
					else
						# Try to convert into a explicit paths list:
						@files << Paths.new(list)
					end
				end
				
				@files.freeze
				@roots = roots
			end
			
			attr :files
			
			def freeze
				self.roots
				
				super
			end
			
			def each
				return to_enum(:each) unless block_given?
				
				@files.each do |files|
					files.each{|path| yield path}
				end
			end
			
			def roots
				@roots ||= @files.collect(&:roots).flatten.uniq
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @files.eql?(other.files)
			end
		
			def hash
				@files.hash
			end
			
			def +(list)
				if list.kind_of? Composite
					self.class.new(@files + list.files)
				else
					self.class.new(@files + [list])
				end
			end
		
			def include?(path)
				@files.any? {|list| list.include?(path)}
			end
		
			def rebase(root)
				self.class.new(@files.collect{|list| list.rebase(root)}, [root])
			end
		
			def to_paths
				self.class.new(@files.collect(&:to_paths), roots: @roots)
			end
			
			def inspect
				"<Composite #{@files.inspect}>"
			end
		end
		
		List::NONE = Composite.new([]).freeze
	end
end
