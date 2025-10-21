# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015-2025, by Samuel Williams.

require "build/files"
require "build/files/path"
require "build/files/system"

require "pathname"

include Build::Files

describe Build::Files::Path do
	let(:root) {Path.new(__dir__)}
	let(:path) {root + ".system-test-#{object_id}"}
	
	after do
		path.delete
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
	
	it "can copy files" do
		path.create
		source_path = Path.new(__dir__)/".directory"
		
		directory = Directory.new(source_path)
		directory.copy(path)
		
		destination_directory = Directory.new(path)
		expect(destination_directory).not.to be(:empty?)
	end
	
	it "can check file properties" do
		path.write("test content")
		
		expect(path.file?).to be == true
		expect(path.symlink?).to be == false
		expect(path.readable?).to be == true
		
		stat = path.stat
		expect(stat).to be_a File::Stat
	end
	
	it "can copy directory to destination" do
		source_dir = path / "source"
		source_dir.create
		
		file_in_dir = source_dir / "test.txt"
		file_in_dir.write("content")
		
		dest_dir = path / "dest"
		
		source_dir.copy(dest_dir)
		expect(dest_dir).to be(:directory?)
	end
end

describe "List file operations" do
	let(:root) {Path.new(__dir__)}
	let(:base_path) {root + ".list-test-#{object_id}"}
	
	after do
		base_path.delete
	end
	
	it "can check if all files exist" do
		base_path.create
		
		file1 = base_path / "file1.txt"
		file2 = base_path / "file2.txt"
		
		file1.write("content1")
		file2.write("content2")
		
		paths = Paths.new([file1, file2])
		expect(paths.exist?).to be == true
	end
	
	it "can create all paths" do
		paths = Paths.new([
			base_path / "dir1",
			base_path / "dir2"
		])
		
		paths.create
		
		expect(paths.first).to be(:directory?)
	end
	
	it "can delete all paths" do
		base_path.create
		
		file1 = base_path / "file1.txt"
		file2 = base_path / "file2.txt"
		
		file1.write("content1")
		file2.write("content2")
		
		paths = Paths.new([file1, file2])
		paths.delete
		
		expect(file1).not.to be(:exist?)
		expect(file2).not.to be(:exist?)
	end
end
