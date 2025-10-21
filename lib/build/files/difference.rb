# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		# Represents a list of files with exclusions applied.
		class Difference < List
			# Initialize a difference list.
			# @parameter list [List] The base list of files.
			# @parameter excludes [List] The list of files to exclude.
			def initialize(list, excludes)
				@list = list
				@excludes = excludes
			end
			
			attr :files
			
			# Freeze the difference list and its dependencies.
			def freeze
				@list.freeze
				@excludes.freeze
				
				super
			end
			
			# Iterate over files in the base list, excluding those in the exclusion list.
			# @yields {|path| ...} Each path not in the exclusion list.
			#   @parameter path [Path] The current file path.
			def each
				return to_enum(:each) unless block_given?
				
				@list.each do |path|
					yield path unless @excludes.include?(path)
				end
			end
			
			# Subtract additional files from this difference.
			# @parameter list [List] Additional files to exclude.
			# @returns [Difference] A new difference with expanded exclusions.
			def -(list)
				self.class.new(@list, Composite.new([@excludes, list]))
			end
			
			# Check if the difference includes a specific path.
			# @parameter path [Path] The path to check.
			# @returns [Boolean] True if the path is in the base list but not excluded.
			def include?(path)
				@list.include?(path) and !@excludes.include?(path)
			end
			
			# Rebase the difference to a new root.
			# @parameter root [Path] The new root path.
			# @returns [Difference] A new difference with rebased files.
			def rebase(root)
				self.class.new(@list.rebase(root), @excludes.rebase(root))
			end
			
			# Generate a string representation for debugging.
			# @returns [String] A debug string showing the difference structure.
			def inspect
				"<Difference #{@list.inspect} - #{@excludes.inspect}>"
			end
		end
	end
end
