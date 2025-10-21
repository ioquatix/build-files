# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require_relative "list"

require "forwardable"

module Build
	module Files
		# A stateful list of files captured at a specific time, which can then be checked for changes.
		class State < List
			extend Forwardable
			
			# Represents a specific file on disk with a specific mtime.
			class FileTime
				include Comparable
				
				# Initialize a file time record.
				# @parameter path [Path] The file path.
				# @parameter time [Time] The modification time.
				def initialize(path, time)
					@path = path
					@time = time
				end
				
				attr :path
				attr :time
				
				# Compare file times for ordering.
				# @parameter other [FileTime] The other file time to compare.
				# @returns [Integer] -1, 0, or 1 for less than, equal, or greater than.
				def <=> other
					@time <=> other.time
				end
				
				# Generate a string representation for debugging.
				# @returns [String] A debug string showing path and time.
				def inspect
					"<FileTime #{@path.inspect} #{@time.inspect}>"
				end
			end
			
			# Initialize file state tracking.
			# @parameter files [List] The list of files to track.
			# @raises [ArgumentError] If files is not a Files::List.
			def initialize(files)
				raise ArgumentError.new("Invalid files list: #{files}") unless Files::List === files
				
				@files = files
				
				@times = {}
				
				update!
			end
			
			attr :files
			
			attr :added
			attr :removed
			attr :changed
			attr :missing
			
			attr :times
			
			def_delegators :@files, :each, :roots, :count
			
			# Update the state by checking all files for changes.
			# @returns [Boolean] True if any files were added, changed, removed, or are missing.
			def update!
				last_times = @times
				@times = {}
				
				@added = []
				@removed = []
				@changed = []
				@missing = []
				
				file_times = []
				
				@files.each do |path|
					# When processing the same path twice (perhaps by accident), we should skip it otherwise it might cause issues when being deleted from last_times multuple times.
					next if @times.include? path
					
					if File.exist?(path)
						modified_time = File.mtime(path)
						
						if last_time = last_times.delete(path)
							# Path was valid last update:
							if modified_time != last_time
								@changed << path
								
								# puts "Changed: #{path}"
							end
						else
							# Path didn't exist before:
							@added << path
							
							# puts "Added: #{path}"
						end
						
						@times[path] = modified_time
						
						unless File.directory?(path)
							file_times << FileTime.new(path, modified_time)
						end
					else
						@missing << path
						
						# puts "Missing: #{path}"
					end
				end
				
				@removed = last_times.keys
				# puts "Removed: #{@removed.inspect}" if @removed.size > 0
				
				@oldest_time = file_times.min
				@newest_time = file_times.max
				
				return @added.size > 0 || @changed.size > 0 || @removed.size > 0 || @missing.size > 0
			end
			
			attr :oldest_time
			attr :newest_time
			
			# Check if any files are missing.
			# @returns [Boolean] True if any files do not exist.
			def missing?
				!@missing.empty?
			end
			
			# Check if the state is empty.
			# @returns [Boolean] True if no files are being tracked.
			def empty?
				@times.empty?
			end
			
			# Generate a string representation for debugging.
			# @returns [String] A debug string showing state changes.
			def inspect
				"<State Added:#{@added} Removed:#{@removed} Changed:#{@changed} Missing:#{@missing}>"
			end
			
			# Are these (output) files dirty with respect to the given inputs?
			def dirty?(inputs)
				if self.missing?
					return true
				end
				
				# If there are no inputs or no outputs, we are always clean:
				if inputs.empty? or self.empty?
					return false
				end
				
				oldest_output_time = self.oldest_time
				newest_input_time = inputs.newest_time
				
				if newest_input_time and oldest_output_time
					# We are dirty if any inputs are newer (bigger) than any outputs:
					if newest_input_time > oldest_output_time
						return true
					else
						return false
					end
				end
				
				return true
			end
			
			# Check if outputs are dirty with respect to inputs.
			# @parameter inputs [State] The input files state.
			# @parameter outputs [State] The output files state.
			# @returns [Boolean] True if outputs need to be regenerated.
			def self.dirty?(inputs, outputs)
				outputs.dirty?(inputs)
			end
		end
	end
end
