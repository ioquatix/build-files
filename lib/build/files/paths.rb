# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		# Represents an explicit list of file paths.
		class Paths < List
			# Initialize a paths list.
			# @parameter list [Array] The array of paths.
			# @parameter roots [Array(Path) | Nil] The root paths, if known.
			def initialize(list, roots = nil)
				@list = Array(list).freeze
				@roots = roots
			end
			
			attr :list
			
			# The list of roots for a given list of immutable files is also immutable, so we cache it for performance:
			def roots
				@roots ||= super
			end
			
			# Get the count of paths in the list.
			# @returns [Integer] The number of paths.
			def count
				@list.count
			end
			
			# Iterate over all paths in the list.
			# @yields {|path| ...} Each path in the list.
			#   @parameter path [Path] The current path.
			def each
				return to_enum(:each) unless block_given?
				
				@list.each{|path| yield path}
			end
			
			# Check equality with another paths list.
			# @parameter other [Paths] The other paths list to compare.
			# @returns [Boolean] True if both have the same paths.
			def eql?(other)
				self.class.eql?(other.class) and @list.eql?(other.list)
			end
			
			# Compute the hash value for this paths list.
			# @returns [Integer] The hash value based on the list.
			def hash
				@list.hash
			end
			
			# Return this paths list unchanged.
			# @returns [Paths] Self.
			def to_paths
				self
			end
			
			# Generate a string representation for debugging.
			# @returns [String] A debug string showing the paths.
			def inspect
				"<Paths #{@list.inspect}>"
			end
			
			# Create a paths list from a directory root and relative paths.
			# @parameter root [Path] The root directory.
			# @parameter relative_paths [Array(String)] The relative paths.
			# @returns [Paths] A new paths list.
			def self.directory(root, relative_paths)
				paths = relative_paths.collect do |path|
					Path.join(root, path)
				end
				
				self.new(paths, [root])
			end
		end
		
		class Path
			# Create a paths list from relative paths under this path.
			# @parameter relative_paths [Array(String)] The relative paths.
			# @returns [Paths] A new paths list.
			def list(*relative_paths)
				Paths.directory(self, relative_paths)
			end
		end
	end
end
