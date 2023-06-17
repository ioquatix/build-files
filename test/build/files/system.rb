# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2023, by Samuel Williams.

require 'build/files'
require 'build/files/path'
require 'build/files/system'

require 'pathname'

include Build::Files

describe Build::Files::Path do
	let(:root) {Path.new(__dir__)}
	let(:path) {root + ".system-test-#{object_id}"}
	
	def after
		path.delete
		super
	end
	
	it "should open file for writing" do
		path.write("Hello World")
		
		expect(File).to be(:exist?, path)
		expect(path.read).to be == "Hello World"
		
		expect(path).to be(:exist?)
		expect(path.directory?).to be == false
		
		expect(path.modified_time.to_f).to be_within(5.0).of(Time.now.to_f)
	end
	
	it "should make a directory" do
		path.create
		
		expect(path.directory?).to be == true
	end
end
