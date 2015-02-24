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
require 'build/files/path/filesystem'
require 'build/files/directory'

module Build::Files::MonitorSpec
	include Build::Files
	
	ROOT = File.expand_path('../tmp', __FILE__)
	
	describe Build::Files::Monitor do
		let(:path) {Path.new(ROOT) + "test.txt"}
		
		before(:all) do
			Path.new(ROOT).mkpath
		end
		
		after(:all) do
			Path.new(ROOT).rmpath
		end
		
		it 'should detect additions' do
			directory = Build::Files::Directory.new(ROOT)
			monitor = Build::Files::Monitor.new
			
			changed = false
			
			monitor.track_changes(directory) do |state|
				changed = state.added.include? path
			end
			
			thread = Thread.new do
				sleep 1.0
				
				path.touch
			end
			
			triggered = 0
			
			monitor.run do
				triggered += 1
				
				throw :interrupt
			end
			
			thread.join
			
			expect(changed).to be true
			expect(triggered).to be == 1
		end
	end
end
