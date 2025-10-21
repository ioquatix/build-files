# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "build/files"
require "build/files/difference"

include Build::Files

describe Build::Files::Difference do
	let(:all_paths) {Paths.new([
		Path.new("/foo/bar"),
		Path.new("/foo/baz"),
		Path.new("/foo/qux")
	])}
	
	let(:exclude_paths) {Paths.new([
		Path.new("/foo/baz")
	])}
	
	it "can create difference" do
		diff = Difference.new(all_paths, exclude_paths)
		
		expect(diff.count).to be == 2
		expect(diff).to be(:include?, Path.new("/foo/bar"))
		expect(diff).not.to be(:include?, Path.new("/foo/baz"))
	end
	
	it "can freeze difference" do
		diff = Difference.new(all_paths, exclude_paths)
		diff.freeze
		
		expect(diff).to be(:frozen?)
	end
	
	it "can subtract more paths" do
		diff = Difference.new(all_paths, exclude_paths)
		more_excludes = Paths.new([Path.new("/foo/qux")])
		
		diff2 = diff - more_excludes
		
		# After subtracting baz and qux, only bar remains
		expect(diff2.count).to be == 1
		expect(diff2).to be(:include?, Path.new("/foo/bar"))
		expect(diff2).not.to be(:include?, Path.new("/foo/baz"))
		expect(diff2).not.to be(:include?, Path.new("/foo/qux"))
	end
	
	it "can rebase difference" do
		diff = Difference.new(all_paths, exclude_paths)
		rebased = diff.rebase("/new/root")
		
		expect(rebased).to be_a Difference
	end
	
	it "can inspect difference" do
		diff = Difference.new(all_paths, exclude_paths)
		inspect_str = diff.inspect
		
		expect(inspect_str).to be(:include?, "Difference")
	end
end
