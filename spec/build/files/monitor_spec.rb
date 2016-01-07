#!/usr/bin/env rspec

# Copyright, 2015, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'build/files/monitor'
require 'build/files/path'
require 'build/files/system'
require 'build/files/directory'

module Build::Files::MonitorSpec
	include Build::Files
	
	ROOT = File.expand_path('../tmp', __FILE__)
	
	describe Build::Files::Monitor do
		shared_examples_for Monitor do |driver|
			let(:path) {Path.new(ROOT) + "test.txt"}
			
			before(:all) do
				Path.new(ROOT).create
			end
			
			after(:all) do
				Path.new(ROOT).delete
			end
			
			it 'should detect additions' do
				directory = Build::Files::Directory.new(ROOT)
				monitor = Build::Files::Monitor.new
				
				changed = false
				
				monitor.track_changes(directory) do |state|
					changed = state.added.include? path
				end
				
				touched = false
				triggered = 0
				
				thread = Thread.new do
					while triggered == 0 or touched == false
						sleep 0.1 if touched
						
						path.touch
						touched = true
					end
				end
				
				monitor.run(driver: driver) do
					triggered += 1
					
					throw :interrupt if touched
				end
				
				thread.join
				
				expect(changed).to be true
				expect(triggered).to be >= 1
			end
		end
		
		# Use the cross-platform driver, :polling
		it_behaves_like Monitor, :polling
		
		# Use the native platform driver, e.g. fsevent or inotify.
		it_behaves_like Monitor
		
		it "should add and remove monitored paths" do
			directory = Build::Files::Directory.new(ROOT)
			monitor = Build::Files::Monitor.new
			
			handler = monitor.track_changes(directory) do |state|
			end
			
			expect(monitor.roots).to be_include ROOT
			
			handler.remove!
			
			expect(monitor.roots).to be_empty
		end
	end
end
