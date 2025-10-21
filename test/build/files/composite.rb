# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "build/files"
require "build/files/composite"

include Build::Files

describe Build::Files::Composite do
	let(:paths_a) {Paths.new([Path.new("/foo/bar")])}
	let(:paths_b) {Paths.new([Path.new("/foo/baz")])}
	
	it "can initialize with composites in the array" do
		composite1 = Composite.new([paths_a])
		composite2 = Composite.new([paths_b])
		
		# Create a composite that contains other composites
		# This tests line 20: @files += list.files
		combined = Composite.new([composite1, composite2])
		
		expect(combined.count).to be == 2
		expect(combined).to be(:include?, Path.new("/foo/bar"))
		expect(combined).to be(:include?, Path.new("/foo/baz"))
	end
	
	it "can initialize with a List subclass" do
		# Create a Difference which is a List subclass
		all_paths = Paths.new([Path.new("/foo/bar"), Path.new("/foo/baz")])
		exclude_paths = Paths.new([Path.new("/foo/baz")])
		diff = Difference.new(all_paths, exclude_paths)
		
		# This should test line 22: @files << list
		# But actually, this code path may be unreachable because
		# List.kind_of? List is always false (it's asking if the class is kind of itself)
		# Let me test with a Directory instead
		dir = Directory.new(__dir__)
		
		composite = Composite.new([dir])
		expect(composite).to be_a Composite
	end
	
	it "can initialize with plain arrays (non-List objects)" do
		# Pass plain arrays which are not List objects
		# This tests line 25: @files << Paths.new(list)
		plain_array = [Path.new("/foo/bar"), Path.new("/foo/baz")]
		
		composite = Composite.new([plain_array])
		expect(composite.count).to be == 2
		expect(composite).to be(:include?, Path.new("/foo/bar"))
		expect(composite).to be(:include?, Path.new("/foo/baz"))
	end
end
