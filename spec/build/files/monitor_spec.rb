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

RSpec.shared_examples_for Monitor do |driver|
	let(:root) {Build::Files::Path.expand('tmp', __dir__)}
	let(:path) {root + "test.txt"}
	
	before do
		root.delete
		root.create
	end
	
	let(:directory) {Build::Files::Directory.new(root)}
	let(:monitor) {Build::Files::Monitor.new}
	
	it "should include touched path" do
		path.touch
		
		expect(directory.to_a).to include(path)
	end
	
	it 'should detect additions' do
		changed = false
		
		monitor.track_changes(directory) do |state|
			changed = true
			
			expect(state.added).to include(path)
		end
		
		thread = Thread.new do
			sleep 1
			path.touch
		end
		
		monitor.run do
			throw :interrupt if changed
		end
		
		thread.join
		
		expect(changed).to be true
	end
	
	it "should add and remove monitored paths" do
		handler = monitor.track_changes(directory) do |state|
			# Do nothing.
		end
		
		expect(monitor.roots).to be_include root
		
		handler.remove!
		
		expect(monitor.roots).to be_empty
	end
end

RSpec.describe Build::Files::Monitor::Polling do
	it_behaves_like Monitor
end

if defined? Build::Files::Monitor::Native
	RSpec.describe Build::Files::Monitor::Native do
		it_behaves_like Monitor
	end
end