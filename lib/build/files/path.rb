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

module Build
	module Files
		# Represents a file path with an absolute root and a relative offset:
		class Path
			def self.split(path)
				# Effectively dirname and basename:
				dirname, separator, filename = path.rpartition(File::SEPARATOR)
				filename, dot, extension = filename.rpartition('.')
				
				return dirname + separator, filename, dot + extension
			end
			
			# Returns the length of the prefix which is shared by two strings.
			def self.prefix_length(a, b)
				[a.size, b.size].min.times{|i| return i if a[i] != b[i]}
			end
			
			# Returns a list of components for a path, either represented as a Path instance or a String.
			def self.components(path)
				if Path === path
					path.components
				else
					path.split(File::SEPARATOR)
				end
			end
			
			# Return the shortest relative path to get to path from root. Root should be a directory with which you are computing the relative path.
			def self.shortest_path(path, root)
				path_components = Path.components(path)
				root_components = Path.components(root)
				
				# Find the common prefix:
				i = prefix_length(path_components, root_components) || 0
				
				# The difference between the root path and the required path, taking into account the common prefix:
				up = root_components.size - i
				
				return File.join([".."] * up + path_components[i..-1])
			end
			
			def self.relative_path(root, full_path)
				relative_offset = root.length
				
				# Deal with the case where the root may or may not end with the path separator:
				relative_offset += 1 unless root.end_with?(File::SEPARATOR)
				
				return full_path.slice(relative_offset..-1)
			end
			
			def self.[] path
				self === path ? path : self.new(path.to_s)
			end
			
			# Both paths must be full absolute paths, and path must have root as an prefix.
			def initialize(full_path, root = nil, relative_path = nil)
				# This is the object identity:
				@full_path = full_path
				
				if root
					@root = root
					@relative_path = relative_path
				else
					# Effectively dirname and basename:
					@root, _, @relative_path = full_path.rpartition(File::SEPARATOR)
				end
				
				# This improves the cost of hash/eql? slightly but the root cannot be deconstructed if it was an instance of Path.
				# @root = @root.to_s
			end
			
			attr :root
			attr :full_path
			
			def length
				@full_path.length
			end
			
			def components
				@components ||= @full_path.split(File::SEPARATOR).freeze
			end
			
			def basename
				self.parts.last
			end
			
			def start_with?(*args)
				@full_path.start_with?(*args)
			end
			
			alias parts components
			
			def relative_path
				@relative_path ||= Path.relative_path(@root.to_s, @full_path).freeze
			end
			
			def relative_parts
				dirname, _, basename = self.relative_path.rpartition(File::SEPARATOR)
				
				return dirname, basename
			end
			
			def append(extension)
				self.class.new(@full_path + extension, @root)
			end
			
			def +(path)
				self.class.new(File.join(@full_path, path), @root)
			end
			
			# Define a new root with a sub-path:
			def /(path)
				self.class.new(File.join(self, path), self)
			end
			
			def rebase(root)
				self.class.new(File.join(root, relative_path), root)
			end
			
			def with(root: @root, extension: nil, basename: false)
				relative_path = self.relative_path
				
				if basename
					dirname, filename, _ = self.class.split(relative_path)
					
					# Replace the filename if the basename is supplied:
					filename = basename if basename.is_a? String
					
					relative_path = dirname + filename
				end
				
				if extension
					relative_path = relative_path + extension
				end
				
				self.class.new(File.join(root, relative_path), root, relative_path)
			end
			
			def self.join(root, relative_path)
				self.new(File.join(root, relative_path), root)
			end
			
			# Expand a subpath within a given root, similar to `File.expand_path`
			def self.expand(subpath, root = Dir.getwd)
				if subpath.start_with? File::SEPARATOR
					self.new(subpath)
				else
					self.join(root, subpath)
				end
			end
			
			def shortest_path(root)
				self.class.shortest_path(self, root)
			end
			
			def to_str
				@full_path
			end
			
			def to_path
				@full_path
			end
			
			def to_s
				@full_path
			end
			
			def inspect
				"#{@root.inspect}/#{relative_path.inspect}"
			end
			
			def hash
				[@root, @full_path].hash
			end
			
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root) and @full_path.eql?(other.full_path)
			end
			
			def ==(other)
				self.to_s == other.to_s
			end
			
			def for_reading
				[@full_path, File::RDONLY]
			end
			
			def for_writing
				[@full_path, File::CREAT|File::TRUNC|File::WRONLY]
			end
			
			def for_appending
				[@full_path, File::CREAT|File::APPEND|File::WRONLY]
			end
		end
	end
end
