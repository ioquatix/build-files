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

require 'build/files/state'

module Build
	module Files
		class Handle
			def initialize(monitor, files, &block)
				@monitor = monitor
				@state = State.new(files)
				@on_changed = block
			end
		
			attr :monitor
		
			def commit!
				@state.update!
			end
		
			def directories
				@state.files.roots
			end
		
			def remove!
				monitor.delete(self)
			end
		
			def changed!
				@on_changed.call(@state) if @state.update!
			end
		end
		
		class Monitor
			def initialize
				@directories = Hash.new { |hash, key| hash[key] = Set.new }
				
				@updated = false
				
				@deletions = nil
			end
			
			attr :updated
			
			# Notify the monitor that files in these directories have changed.
			def update(directories, *args)
				delay_deletions do
					directories.each do |directory|
						# directory = File.realpath(directory)
						
						@directories[directory].each do |handle|
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
				handle.directories.each do |directory|
					@directories[directory] << handle
					
					# We just added the first handle:
					if @directories[directory].size == 1
						# If the handle already existed, this might trigger unnecessarily.
						@updated = true
					end
				end
				
				handle
			end
			
			def run(options = {}, &block)
				default_driver = case RUBY_PLATFORM
					when /linux/i; :inotify
					when /darwin/i; :fsevent
					else; :polling
				end
				
				if driver = (options[:driver] || default_driver)
					method_name = "run_with_#{driver}"
					Files.send(method_name, self, options, &block)
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
				handle.directories.each do |directory|
					@directories[directory].delete(handle)
					
					# Remove the entire record if there are no handles:
					if @directories[directory].size == 0
						@directories.delete(directory)
						
						@updated = true
					end
				end
			end
		end
		
		def self.run_with_inotify(monitor, options = {}, &block)
			require 'rb-inotify'
			
			notifier = INotify::Notifier.new
			
			catch(:interrupt) do
				while true
					monitor.roots.each do |root|
						notifier.watch root, :create, :modify, :delete do |event|
							monitor.update([root])
							
							yield
							
							if monitor.updated
								notifier.stop
							end
						end
					end
					
					notifier.run
				end
			end
		end
		
		def self.run_with_fsevent(monitor, options = {}, &block)
			require 'rb-fsevent'
			
			notifier = FSEvent.new
			
			catch(:interrupt) do
				while true
					notifier.watch monitor.roots do |directories|
						directories.collect!{|directory| File.expand_path(directory)}
						
						monitor.update(directories)
						
						yield
						
						if monitor.updated
							notifier.stop
						end
					end
					
					notifier.run
				end
			end
		end
		
		def self.run_with_polling(monitor, options = {}, &block)
			catch(:interrupt) do
				while true
					monitor.update(monitor.roots)
					
					yield
					
					sleep(options[:latency] || 1.0)
				end
			end
		end
	end
end
