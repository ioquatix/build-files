# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2023, by Samuel Williams.

require 'fileutils'

require_relative 'path'
require_relative 'list'

module Build
	module Files
		class Path
			# Open a file with the specified mode.
			def open(mode, &block)
				File.open(self, mode, &block)
			end
			
			# Read the entire contents of the file.
			def read(mode = File::RDONLY)
				open(mode) do |file|
					file.read
				end
			end
			
			# Write a buffer to the file, creating it if it doesn't exist. 
			def write(buffer, mode = File::CREAT|File::TRUNC|File::WRONLY)
				open(mode) do |file|
					file.write(buffer)
				end
			end
			
			# Touch the file, changing it's last modified time.
			def touch
				FileUtils.touch self
			end
			
			def stat
				File.stat self
			end
			
			# Checks if the file exists in the local file system.
			def exist?
				File.exist? self
			end
			
			# Checks if the path refers to a directory.
			def directory?
				File.directory? self
			end
			
			def file?
				File.file? self
			end
			
			def symlink?
				File.symlink? self
			end
			
			def readable?
				File.readable? self
			end
			
			# The time the file was last modified.
			def modified_time
				File.mtime self
			end
			
			# Recursively create a directory hierarchy for the given path.
			def mkpath
				FileUtils.mkpath self
			end
			
			alias create mkpath
			
			# Recursively delete the given path and all contents.
			def rm
				FileUtils.rm_rf self
			end
			
			alias delete rm
		end
		
		class List
			# Touch all listed files.
			def touch
				each(&:touch)
			end
			
			# Check that all files listed exist.
			def exist?
				all?(&:exist?)
			end
			
			# Recursively create paths for all listed paths.
			def create
				each(&:create)
			end
			
			# Recursively delete all paths and all contents within those paths.
			def delete
				each(&:delete)
			end
		end
	end
end
