# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2025, by Samuel Williams.

require_relative "list"

module Build
	module Files
		# Represents a composite list of files from multiple sources.
		class Composite < List
			# Initialize a composite list with multiple file lists.
			# @parameter files [Array] The file lists to combine.
			# @parameter roots [Array(Path) | Nil] The root paths, if known.
			def initialize(files, roots = nil)
				@files = []
				
				files.each do |list|
					if list.kind_of? Composite
						@files += list.files
					elsif list.kind_of? List
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
			
			# Freeze the composite list and its dependencies.
			def freeze
				self.roots
				
				super
			end
			
			# Iterate over all files in the composite list.
			# @yields {|path| ...} Each path in all combined lists.
			#   @parameter path [Path] The current file path.
			def each
				return to_enum(:each) unless block_given?
				
				@files.each do |files|
					files.each{|path| yield path}
				end
			end
			
			# Get all root paths for all lists in the composite.
			# @returns [Array(Path)] The unique root paths.
			def roots
				@roots ||= @files.collect(&:roots).flatten.uniq
			end
			
			# Check equality with another composite list.
			# @parameter other [Composite] The other composite to compare.
			# @returns [Boolean] True if both composites have the same files.
			def eql?(other)
				self.class.eql?(other.class) and @files.eql?(other.files)
			end
			
			# Compute the hash value for this composite.
			# @returns [Integer] The hash value based on files.
			def hash
				@files.hash
			end
			
			# Combine this composite with another list.
			# @parameter list [List] The list to add.
			# @returns [Composite] A new composite containing both lists.
			def +(list)
				if list.kind_of? Composite
					self.class.new(@files + list.files)
				else
					self.class.new(@files + [list])
				end
			end
			
			# Check if the composite includes a specific path.
			# @parameter path [Path] The path to check.
			# @returns [Boolean] True if any list in the composite includes the path.
			def include?(path)
				@files.any? {|list| list.include?(path)}
			end
			
			# Rebase all lists in the composite to a new root.
			# @parameter root [Path] The new root path.
			# @returns [Composite] A new composite with rebased lists.
			def rebase(root)
				self.class.new(@files.collect{|list| list.rebase(root)}, [root])
			end
			
			# Convert all lists in the composite to paths.
			# @returns [Composite] A new composite with all lists converted to paths.
			def to_paths
				self.class.new(@files.collect(&:to_paths), roots: @roots)
			end
			
			# Generate a string representation for debugging.
			# @returns [String] A debug string showing the composite structure.
			def inspect
				"<Composite #{@files.inspect}>"
			end
		end
		
		List::NONE = Composite.new([]).freeze
	end
end
