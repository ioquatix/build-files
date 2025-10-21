# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		# Represents a directory of files.
		class Directory < List
			# Join path components and create a directory.
			# @parameter args [Array(String)] The path components to join.
			# @returns [Directory] A new directory at the joined path.
			def self.join(*args)
				self.new(Path.join(*args))
			end
			
			# Initialize a directory with a root path.
			# @parameter root [Path | String] The root path of the directory.
			def initialize(root)
				@root = root
			end
			
			# Get the root path of the directory.
			# @returns [Path] The root path.
			def root
				@root
			end
			
			# Get the root paths as an array.
			# @returns [Array(Path)] An array containing the single root path.
			def roots
				[root]
			end
			
			# Iterate over all files in the directory recursively.
			# @yields {|path| ...} Each file path in the directory.
			#   @parameter path [Path] The current file path.
			def each
				return to_enum(:each) unless block_given?
				
				# We match both normal files with * and dotfiles with .?*
				Dir.glob(@root + "**/{*,.?*}") do |path|
					yield Path.new(path, @root)
				end
			end
			
			# Check equality with another directory.
			# @parameter other [Directory] The other directory to compare.
			# @returns [Boolean] True if both directories have the same root.
			def eql?(other)
				self.class.eql?(other.class) and @root.eql?(other.root)
			end
			
			# Compute the hash value for this directory.
			# @returns [Integer] The hash value based on the root.
			def hash
				@root.hash
			end
			
			# Check if the directory includes a specific path.
			# @parameter path [Path] The path to check.
			# @returns [Boolean] True if the path is within this directory.
			def include?(path)
				# Would be true if path is a descendant of full_path.
				path.start_with?(@root)
			end
			
			# Rebase the directory to a new root.
			# @parameter root [Path] The new root path.
			# @returns [Directory] A new directory with the rebased root.
			def rebase(root)
				self.class.new(@root.rebase(root))
			end
			
			# Convert the directory to a string for use as a command argument.
			# @returns [String] The root path as a string.
			def to_str
				@root.to_str
			end
			
			# Convert the directory to a string.
			# @returns [String] The root path as a string.
			def to_s
				to_str
			end
			
			# Convert the directory to a path object.
			# @returns [Path] The root path.
			def to_path
				@root
			end
		end
	end
end
