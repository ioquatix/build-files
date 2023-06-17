# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2023, by Samuel Williams.

require 'build/files'
require 'build/files/path'

require 'pathname'

describe Build::Files::Path do
	it "can get current path" do
		expect(Build::Files::Path.current.full_path).to be == Dir.pwd
	end
	
	it "should expand the path" do
		expect(Build::Files::Path.expand("foo", "/bar")).to be == "/bar/foo"
	end
	
	it "should give current path" do
		path = Build::Files::Path.new("/a/b/c/file.cpp")
		
		expect(path.shortest_path(path)).to be == "."
	end
	
	it "should give the shortest path for outer paths" do
		input = Build::Files::Path.new("/a/b/c/file.cpp")
		output = Build::Files::Path.new("/a/b/c/d/e/")
		
		expect(input.root).to be == "/a/b/c"
		expect(output.root).to be == "/a/b/c/d/e"
		
		short = input.shortest_path(output)
		
		expect(short).to be == "../../file.cpp"
		
		expect(File.expand_path(short, output)).to be == input
	end
	
	it "should give the shortest path for inner paths" do
		input = Build::Files::Path.new("/a/b/c/file.cpp")
		output = Build::Files::Path.new("/a/")
		
		expect(input.root).to be == "/a/b/c"
		expect(output.root).to be == "/a"
		
		short = input.shortest_path(output)
		
		expect(short).to be == "b/c/file.cpp"
		
		expect(File.expand_path(short, output)).to be == input
	end
	
	with "test directory"  do
		let(:directory) {Build::Files::Path.new("/test")}
		
		it "should start_with? full path" do
			expect(directory).to be(:start_with?, '/test')
		end
		
		it "should start_with? partial pattern" do
			expect(directory).to be(:start_with?, '/te')
		end
	end
	
	with "text file path" do
		let(:path) {Build::Files::Path.new("/foo/bar.txt")}
	
		it "should replace existing file extension" do
			expect(path.with(extension: '.jpeg', basename: true)).to be == "/foo/bar.jpeg"
		end
		
		it "should append file extension" do
			expect(path.with(extension: '.jpeg')).to be == "/foo/bar.txt.jpeg"
		end
		
		it "should change basename" do
			expect(path.with(basename: 'baz', extension: '.txt')).to be == "/foo/baz.txt"
		end	
	end
end

describe Build::Files::Path.new("/foo") do
	it "can compute parent path" do
		parent = subject.parent
		
		expect(parent.root).to be == ""
		expect(parent.relative_path).to be == ""
		expect(parent.full_path).to be == "/"
	end
end

describe Build::Files::Path.new("/foo/bar/baz", "/foo") do
	it "can compute parent path" do
		parent = subject.parent
		
		expect(parent.root).to be == subject.root
		expect(parent.relative_path).to be == "bar"
		expect(parent.full_path).to be == "/foo/bar"
	end
	
	it "can compute parent path of child path" do
		child = subject / "blep"
		parent = child.parent
		
		expect(parent.root).to be == subject.root
		expect(parent.relative_path).to be == subject.relative_path
		expect(parent.full_path).to be == subject.full_path
	end
	
	it "can add nil path" do
		expect(subject + nil).to be == subject
	end
	
	it "can inspect path with nil root" do
		expect do
			(subject / nil).inspect
		end.not.to raise_exception
	end
	
	it "can add nil root" do
		expect(subject / nil).to be == subject
	end
	
	it "should be inspectable" do
		expect(subject.inspect).to be(:include?, subject.root.to_s)
		expect(subject.inspect).to be(:include?, subject.relative_path.to_s)
	end
	
	it "should convert to path" do
		pathname = Pathname("/foo/bar/baz")
		
		expect(Build::Files::Path[pathname]).to be == subject
		expect(Build::Files::Path["/foo/bar/baz"]).to be == subject
	end
	
	it "should be equal" do
		expect(subject).to be(:eql?, subject)
		expect(subject).to be == subject
		
		different_root_path = Build::Files::Path.join("/foo/bar", "baz")
		expect(subject).not.to be(:eql?, different_root_path)
		expect(subject).to be == different_root_path
	end
	
	it "should convert to string" do
		expect(subject.to_s).to be == "/foo/bar/baz"
		
		# The to_str method should return the full path (i.e. the same as to_s):
		expect(subject.to_s).to be == subject.to_str
		
		# Check the equality operator:
		expect(subject).to be == subject.dup
		
		# The length should be reported correctly:
		expect(subject.length).to be == subject.to_s.length
		
		# Check the return types:
		expect(subject).to be_a Build::Files::Path
		expect(subject.root).to be_a String
		expect(subject.relative_path).to be_a String
	end
	
	it "should consist of parts" do
		expect(subject.parts).to be == ["", "foo", "bar", "baz"]
		
		expect(subject.root).to be == "/foo"
		
		expect(subject.relative_path).to be == "bar/baz"
		
		expect(subject.relative_parts).to be == ["bar", "baz"]
	end
	
	it "should have a new extension" do
		renamed_path = subject.with(root: '/tmp', extension: '.txt')
		
		expect(renamed_path.root).to be == '/tmp'
		
		expect(renamed_path.relative_path).to be == 'bar/baz.txt'
		
		object_path = subject.append(".o")
	
		expect(object_path.root).to be == "/foo"
		expect(object_path.relative_path).to be == "bar/baz.o"
	end
	
	it "should append a path" do
		subject = Build::Files::Path.new("/a/b/c")
		
		expect(subject + "d/e/f").to be == "/a/b/c/d/e/f"
	end
	
	it "should give a list of components" do
		expect(Build::Files::Path.components(subject)).to be == ["", "foo", "bar", "baz"]
		expect(Build::Files::Path.components(subject.to_s)).to be == ["", "foo", "bar", "baz"]
	end
	
	it "should give a basename" do
		expect(subject.basename).to be == "baz"
	end
	
	it "should have a new root" do
		rerooted_path = subject / "cat"
		
		expect(rerooted_path.root).to be == "/foo/bar/baz"
		expect(rerooted_path.relative_path).to be == "cat"
	end
	
	it "should give correct modes for reading" do
		expect(subject.for_reading).to be == [subject.to_s, File::RDONLY]
	end
	
	it "should give correct modes for writing" do
		expect(subject.for_writing).to be == [subject.to_s, File::CREAT|File::TRUNC|File::WRONLY]
	end
	
	it "should give correct modes for appending" do
		expect(subject.for_appending).to be == [subject.to_s, File::CREAT|File::APPEND|File::WRONLY]
	end
	
	it "should match against relative path" do
		expect(subject.match(subject.relative_path)).to be_truthy
		expect(subject.match("*/baz")).to be_truthy
		expect(subject.match("/baz")).to be_falsey
	end
	
	it "should match against absolute path" do
		expect(subject.match(subject.to_s)).to be_truthy
		expect(subject.match("/foo/**")).to be_truthy
	end
end
