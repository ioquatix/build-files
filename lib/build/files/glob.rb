# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		class Path
			# Create a glob pattern matcher for files under this path.
			# @parameter pattern [String] The glob pattern to match.
			# @returns [Glob] A glob matcher for the pattern.
			def glob(pattern)
				Glob.new(self, pattern)
			end
		end
		
		# Represents a glob pattern for matching files.
		class Glob < List
			# Initialize a glob with a root path and pattern.
			# @parameter root [Path] The root directory for the glob.
			# @parameter pattern [String] The glob pattern to match.
			def initialize(root, pattern)
				@root = root
				@pattern = pattern
			end
			
			attr :root
			attr :pattern
			
			# Get the root paths for this glob.
			# @returns [Array(Path)] An array containing the root path.
			def roots
				[@root]
			end
			
			# Get the full pattern including the root path.
			# @returns [String] The complete glob pattern.
			def full_pattern
				Path.join(@root, @pattern)
			end
			
			# Enumerate all paths matching the pattern.
			def each(&block)
				return to_enum unless block_given?
				
				::Dir.glob(full_pattern, ::File::FNM_DOTMATCH) do |path|
					# Ignore `.` and `..` entries.
					next if path =~ /\/..?$/
					
					yield Path.new(path, @root)
				end
			end
			
			# Check equality with another glob.
			# @parameter other [Glob] The other glob to compare.
			# @returns [Boolean] True if both globs have the same root and pattern.
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root) and @pattern.eql?(other.pattern)
			end
			
			# Compute the hash value for this glob.
			# @returns [Integer] The hash value based on root and pattern.
			def hash
				[@root, @pattern].hash
			end
			
			# Check if a path matches this glob pattern.
			# @parameter path [Path] The path to check.
			# @returns [Boolean] True if the path matches the pattern.
			def include?(path)
				File.fnmatch(full_pattern, path)
			end
			
			# Rebase the glob to a new root.
			# @parameter root [Path] The new root path.
			# @returns [Glob] A new glob with the same pattern under the new root.
			def rebase(root)
				self.class.new(root, @pattern)
			end
			
			# Generate a string representation for debugging.
			# @returns [String] A debug string showing the full pattern.
			def inspect
				"<Glob #{full_pattern.inspect}>"
			end
		end
	end
end
