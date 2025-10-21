# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "path"

module Build
	module Files
		# A list of paths, where #each yields instances of Path.
		class List
			include Enumerable
			
			# Get all unique root paths from the list.
			# @returns [Array(Path)] Sorted unique root paths.
			def roots
				collect{|path| path.root}.sort.uniq
			end
			
			# Create a composite list out of two other lists:
			def +(list)
				Composite.new([self, list])
			end
			
			# Subtract a list from this list.
			# @parameter list [List] The list to subtract.
			# @returns [Difference] A difference list excluding the given paths.
			def -(list)
				Difference.new(self, list)
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
			
			# Check if the list is empty.
			# @returns [Boolean] True if the list contains no paths.
			def empty?
				each do
					return false
				end
				
				return true
			end
			
			# Transform paths with modified attributes.
			# @parameter options [Hash] Options to pass to {Path#with}.
			# @yields {|path, updated_path| ...} Each original and updated path.
			#   @parameter path [Path] The original path.
			#   @parameter updated_path [Path] The modified path.
			# @returns [Paths] A new paths list with transformed paths.
			def with(**options)
				return to_enum(:with, **options) unless block_given?
				
				paths = []
				
				self.each do |path|
					updated_path = path.with(**options)
					
					yield path, updated_path
					
					paths << updated_path
				end
				
				return Paths.new(paths)
			end
			
			# Rebase all paths in the list to a new root.
			# @parameter root [Path] The new root path.
			# @returns [Paths] A new paths list with rebased paths.
			def rebase(root)
				Paths.new(self.collect{|path| path.rebase(root)}, [root])
			end
			
			# Convert the list to a Paths instance.
			# @returns [Paths] A paths list containing all items.
			def to_paths
				Paths.new(each.to_a)
			end
			
			# Map over the list and return a Paths instance.
			# @yields {|path| ...} Each path in the list.
			#   @parameter path [Path] The current path.
			# @returns [Paths] A new paths list with mapped values.
			def map
				Paths.new(super)
			end
			
			# Coerce an argument to a List instance.
			# @parameter arg [List | Object] The object to coerce.
			# @returns [List] A list instance.
			def self.coerce(arg)
				if arg.kind_of? self
					arg
				else
					Paths.new(arg)
				end
			end
			
			# Convert the list to a string.
			# @returns [String] The string representation.
			def to_s
				inspect
			end
		end
	end
end

require_relative "difference"
