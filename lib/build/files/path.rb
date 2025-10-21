# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

module Build
	module Files
		# Represents a file path with an absolute root and a relative offset:
		class Path
			# Get the current working directory as a path.
			# @returns [Path] The current directory path.
			def self.current
				self.new(::Dir.pwd)
			end
			
			# Split a path into directory, filename, and extension components.
			# @parameter path [String] The path to split.
			# @returns [Array(String, String, String)] The directory, filename, and extension.
			def self.split(path)
				# Effectively dirname and basename:
				dirname, separator, filename = path.rpartition(File::SEPARATOR)
				filename, dot, extension = filename.rpartition(".")
				
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
			
			# Get the root directory of a path.
			# @parameter path [Path | String] The path to get the root from.
			# @returns [String] The root directory.
			def self.root(path)
				if Path === path
					path.root
				else
					File.dirname(path)
				end
			end
			
			# Compute the shortest relative path from root to path.
			# @parameter path [Path | String] The target path.
			# @parameter root [Path | String] The root directory.
			# @returns [String] The shortest relative path.
			def self.shortest_path(path, root)
				path_components = Path.components(path)
				root_components = Path.components(root)
				
				# Find the common prefix:
				i = prefix_length(path_components, root_components) || 0
				
				# The difference between the root path and the required path, taking into account the common prefix:
				up = root_components.size - i
				
				components = [".."] * up + path_components[i..-1]
				
				if components.empty?
					return "."
				else
					return File.join(components)
				end
			end
			
			# Compute the relative path from root to full path.
			# @parameter root [String] The root directory.
			# @parameter full_path [String] The full path.
			# @returns [String] The relative path.
			def self.relative_path(root, full_path)
				relative_offset = root.length
				
				# Deal with the case where the root may or may not end with the path separator:
				relative_offset += 1 unless root.end_with?(File::SEPARATOR)
				
				return full_path.slice(relative_offset..-1)
			end
			
			# Convert a path-like object to a Path instance.
			# @parameter path [Path | String] The path to convert.
			# @returns [Path] A Path instance.
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
			end
			
			attr :root
			attr :full_path
			
			# Get the length of the full path.
			# @returns [Integer] The number of characters in the path.
			def length
				@full_path.length
			end
			
			alias size length
			
			# Get the path components as an array.
			# @returns [Array(String)] The path split by directory separator.
			def components
				@components ||= @full_path.split(File::SEPARATOR).freeze
			end
			
			# Get the basename of the path.
			# @returns [String] The last component of the path.
			def basename
				self.parts.last
			end
			
			# Get the parent directory path.
			# @returns [Path] The parent directory.
			def parent
				root = @root
				full_path = File.dirname(@full_path)
				
				while root.size > full_path.size
					root = Path.root(root)
				end
				
				if root.size == full_path.size
					root = Path.root(root)
				end
				
				self.class.new(full_path, root)
			end
			
			# Check if the path starts with the given prefix.
			# @parameter args [Array(String)] The prefix strings to check.
			# @returns [Boolean] True if the path starts with any of the prefixes.
			def start_with?(*args)
				@full_path.start_with?(*args)
			end
			
			alias parts components
			
			# Get the relative path from the root.
			# @returns [String] The path relative to the root.
			def relative_path
				@relative_path ||= Path.relative_path(@root.to_s, @full_path.to_s).freeze
			end
			
			# Split the relative path into directory and basename components.
			# @returns [Array(String, String)] The directory and basename.
			def relative_parts
				dirname, _, basename = self.relative_path.rpartition(File::SEPARATOR)
				
				return dirname, basename
			end
			
			# Append an extension to the path.
			# @parameter extension [String] The extension to append.
			# @returns [Path] A new path with the extension appended.
			def append(extension)
				self.class.new(@full_path + extension, @root)
			end
			
			# Add a path component to the current path.
			# @param path [String, nil] (Optionally) the path to append.
			def +(path)
				if path
					self.class.new(File.join(@full_path, path), @root)
				else
					self
				end
			end
			
			# Use the current path to define a new root, with an optional sub-path.
			# @param path [String, nil] (Optionally) the path to append.
			def /(path)
				if path
					self.class.new(File.join(self, path), self)
				else
					self.class.new(self, self)
				end
			end
			
			# Rebase the path to a new root directory.
			# @parameter root [Path | String] The new root.
			# @returns [Path] A new path with the same relative path under the new root.
			def rebase(root)
				self.class.new(File.join(root, relative_path), root)
			end
			
			# Create a modified path with new root, extension, or basename.
			# @parameter root [Path | String] The new root directory.
			# @parameter extension [String | Nil] An extension to add.
			# @parameter basename [String | Boolean | Nil] A new basename or `true` to keep existing.
			# @returns [Path] A new path with the specified modifications.
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
			
			# Join a root and relative path to create a new Path.
			# @parameter root [String] The root directory.
			# @parameter relative_path [String] The relative path.
			# @returns [Path] A new path combining root and relative path.
			def self.join(root, relative_path)
				self.new(File.join(root, relative_path), root)
			end
			
			# Expand a path within a given root.
			def self.expand(path, root = Dir.getwd)
				if path.start_with?(File::SEPARATOR)
					self.new(path)
				else
					self.join(root, path)
				end
			end
			
			# Compute the shortest path from this path to a root.
			# @parameter root [Path | String] The root directory.
			# @returns [String] The shortest relative path.
			def shortest_path(root)
				self.class.shortest_path(self, root)
			end
			
			# Convert the path to a string.
			# @returns [String] The full path as a string.
			def to_str
				@full_path.to_str
			end
			
			# Convert the path to a path string.
			# @returns [String] The full path.
			def to_path
				@full_path
			end
			
			# Convert the path to a string representation.
			# @returns [String] The full path as a string.
			def to_s
				# It's not guaranteed to be string.
				@full_path.to_s
			end
			
			# Generate a string representation for debugging.
			# @returns [String] A debug string showing root and relative path.
			def inspect
				"#{@root.inspect}/#{relative_path.inspect}"
			end
			
			# Compute the hash value for this path.
			# @returns [Integer] The hash value based on root and full path.
			def hash
				[@root, @full_path].hash
			end
			
			# Check equality with another path.
			# @parameter other [Path] The other path to compare.
			# @returns [Boolean] True if both paths have the same root and full path.
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root) and @full_path.eql?(other.full_path)
			end
			
			include Comparable
			
			# Compare this path with another for sorting.
			# @parameter other [Path] The other path to compare.
			# @returns [Integer] -1, 0, or 1 for less than, equal, or greater than.
			def <=>(other)
				self.to_s <=> other.to_s
			end
			
			# Match a path with a given pattern, using `File#fnmatch`.
			def match(pattern, flags = 0)
				path = pattern.start_with?("/") ? full_path : relative_path
				
				return File.fnmatch(pattern, path, flags)
			end
			
			# Get file opening arguments for reading.
			# @returns [Array] The path and file mode for reading.
			def for_reading
				[@full_path, File::RDONLY]
			end
			
			# Get file opening arguments for writing.
			# @returns [Array] The path and file mode for writing.
			def for_writing
				[@full_path, File::CREAT|File::TRUNC|File::WRONLY]
			end
			
			# Get file opening arguments for appending.
			# @returns [Array] The path and file mode for appending.
			def for_appending
				[@full_path, File::CREAT|File::APPEND|File::WRONLY]
			end
		end
	end
end
