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

require 'set'
require 'logger'

require_relative '../handle'

module Build
	module Files
		module Monitor
			class Polling
				def initialize(logger: nil)
					@directories = Hash.new do |hash, key|
						hash[key] = Set.new
					end
					
					@updated = false
					
					@deletions = nil
					
					@logger = logger || Logger.new(nil)
				end
				
				attr :updated
				
				# Notify the monitor that files in these directories have changed.
				def update(directories, *args)
					@logger.debug{"Update: #{directories} #{args.inspect}"}
					
					delay_deletions do
						directories.each do |directory|
							@logger.debug{"Directory: #{directory}"}
							
							@directories[directory].each do |handle|
								@logger.debug{"Handle changed: #{handle.inspect}"}
								
								# Changes here may not actually require an update to the handle:
								handle.changed!(*args)
							end
						end
					end
				end
				
				def roots
					@directories.keys
				end
				
				def delete(handle)
					if @deletions
						@logger.debug{"Delayed delete handle: #{handle}"}
						@deletions << handle
					else
						purge(handle)
					end
				end
				
				def track_changes(files, &block)
					handle = Handle.new(self, files, &block)
					
					add(handle)
				end
				
				def add(handle)
					@logger.debug{"Adding handle: #{handle}"}
					
					handle.directories.each do |directory|
						# We want the full path as a plain string:
						directory = directory.to_s
						
						@directories[directory] << handle
						
						# We just added the first handle:
						if @directories[directory].size == 1
							# If the handle already existed, this might trigger unnecessarily.
							@updated = true
						end
					end
					
					handle
				end
				
				def run(**options, &block)
					catch(:interrupt) do
						while true
							monitor.update(monitor.roots)
							
							yield
							
							sleep(options[:latency] || 1.0)
						end
					end
				end
				
				protected
				
				def delay_deletions
					@deletions = []
					
					yield
					
					@deletions.each do |handle|
						purge(handle)
					end
					
					@deletions = nil
				end
				
				def purge(handle)
					@logger.debug{"Purge handle: #{handle}"}
					
					handle.directories.each do |directory|
						directory = directory.to_s
						
						@directories[directory].delete(handle)
						
						# Remove the entire record if there are no handles:
						if @directories[directory].size == 0
							@directories.delete(directory)
							
							@updated = true
						end
					end
				end
			end
		end
	end
end
