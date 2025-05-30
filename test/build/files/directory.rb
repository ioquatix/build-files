# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require "build/files/directory"


include Build::Files

describe Build::Files::Directory do
	let(:path) {Path.new("/foo/bar/baz", "/foo")}
	let(:directory) {Directory.new(path)}
	
	it "can be constructed using join" do
		joined_directory = Directory.join("/foo", "bar/baz")
		
		expect(joined_directory).to be == directory
	end
	
	it "has a root and path component" do
		expect(directory.root).to be == path
		expect(directory.to_path).to be == path
		
		expect(directory.roots).to be(:include?, path)
	end
	
	it "can be converted into a string" do
		expect(directory.to_str).to be == path.to_str
	end
	
	it "can be used as a key" do
		hash = {directory => true}
		
		expect(hash).to be(:include?, directory)
	end
	
	it "includes subpaths" do
		expect(directory).to be(:include?, "/foo/bar/baz/bob/dole")
	end
	
	it "can be compared" do
		other_directory = Directory.new(path + "dole")
		
		expect(directory).to be(:eql?, directory)
		expect(directory).not.to be(:eql?, other_directory)
	end
	
	it "can be rebased" do
		rebased_directory = directory.rebase("/fu")
		
		expect(rebased_directory.root).to be == "/fu/bar/baz"
	end
	
	with "real directory" do
		let(:directory) {Directory.join(__dir__, ".directory")}
		
		it "can list dot files" do
			expect(directory).to be(:include?, directory.root + ".dot_file.yaml")
		end
		
		it "can list normal files" do
			expect(directory).to be(:include?, directory.root + "normal_file.txt")
		end
		
		it "can enumerate contents" do
			contents = directory.each.to_a
			expect(contents).to be(:include?, directory.root + ".dot_file.yaml")
		end
	end
	
	with "#to_s" do
		it "can be converted to a string" do
			expect(directory.to_s).to be == "/foo/bar/baz"
		end
	end
end
