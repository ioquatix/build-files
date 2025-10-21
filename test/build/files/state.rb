# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.

require "build/files"
require "build/files/state"

describe Build::Files::State do
	let(:files) {Build::Files::Glob.new(__dir__, "*.rb")}
	
	it "should have no changes initially" do
		state = Build::Files::State.new(files)
		
		expect(state.update!).to be == false
		
		expect(state.changed).to be == []
		expect(state.added).to be == []
		expect(state.removed).to be == []
		expect(state.missing).to be == []
	end
	
	it "can detect file changes" do
		# Create a temporary file
		temp_path = Build::Files::Path.new(__dir__) + ".temp-change-test-#{object_id}"
		temp_path.write("initial content")
		
		begin
			paths = Build::Files::Paths.new([temp_path])
			state = Build::Files::State.new(paths)
			
			# Initial state
			expect(state.update!).to be == false
			
			# Modify the file
			sleep 0.01 # Ensure time difference
			temp_path.write("modified content")
			
			# Update should detect change
			expect(state.update!).to be == true
			expect(state.changed).to be(:include?, temp_path)
		ensure
			temp_path.delete if temp_path.exist?
		end
	end
	
	it "should report missing files" do
		rebased_files = files.to_paths.rebase(File.join(__dir__, "foo"))
		state = Build::Files::State.new(rebased_files)
		
		# Some changes were detected:
		expect(state.update!).to be == true
		
		# Some files are missing:
		expect(state.missing).not.to be(:empty?)
		expect(state.missing?).to be == true
	end
	
	it "can inspect state" do
		state = Build::Files::State.new(files)
		state.update!
		
		inspect_str = state.inspect
		expect(inspect_str).to be(:include?, "State")
	end
	
	it "should not be confused by duplicates" do
		state = Build::Files::State.new(files + files)
		
		expect(state.update!).to be == false
		
		expect(state.changed).to be == []
		expect(state.added).to be == []
		expect(state.removed).to be == []
		expect(state.missing).to be == []
	end
end

describe Build::Files::State do
	before do
		@temporary_files = Build::Files::Paths.directory(__dir__, ["a"])
		@temporary_files.touch
		
		@new_files = Build::Files::State.new(@temporary_files)
		@old_files = Build::Files::State.new(Build::Files::Glob.new(__dir__, "*.rb"))
	end
	
	after do
		@temporary_files.delete
	end
	
	let(:empty) {Build::Files::State.new(Build::Files::List::NONE)}
	
	it "should be clean with empty inputs or outputs" do
		expect(Build::Files::State.dirty?(empty, @new_files)).to be == false
		expect(Build::Files::State.dirty?(@new_files, empty)).to be == false
	end
	
	it "should be clean if files are newer" do
		expect(Build::Files::State.dirty?(@old_files, @new_files)).to be == false
	end
	
	it "should be dirty if files are modified" do
		# In this case, the file mtime is usually different so... 
		expect(Build::Files::State.dirty?(@new_files, @old_files)).to be == true
	end
	
	it "should be dirty if outputs are missing" do
		missing_files = Build::Files::Paths.directory(__dir__, ["nonexistent"])
		missing_state = Build::Files::State.new(missing_files)
		
		expect(missing_state.dirty?(@new_files)).to be == true
	end
	
	it "should fall through to true when newest input is nil" do
		# Create state with files that exist but test edge case
		# where newest_input_time is nil
		temp_file = Build::Files::Path.new(__dir__) + ".temp-nil-test-#{object_id}"
		temp_file.write("test")
		
		begin
			output_state = Build::Files::State.new(Build::Files::Paths.new([temp_file]))
			
			# Create an input state that will have a nil newest_time
			# This happens when there are no regular files (only directories)
			input_dir = temp_file.parent / ".temp-dir-#{object_id}"
			input_dir.create
			
			begin
				input_state = Build::Files::State.new(Build::Files::Paths.new([input_dir]))
				
				# When newest_input_time is nil, should return true (line 168)
				expect(output_state.dirty?(input_state)).to be == true
			ensure
				input_dir.delete if input_dir.exist?
			end
		ensure
			temp_file.delete if temp_file.exist?
		end
	end
end

describe "FileTime" do
	let(:files) {Build::Files::Glob.new(__dir__, "*.rb")}
	
	it "should handle edge case when inputs newer but return false in final fallback" do
		# This tests the edge case where we fall through all conditions
		# Create a state with no files to hit the edge case
		empty_state = Build::Files::State.new(Build::Files::List::NONE)
		non_empty = Build::Files::State.new(files)
		
		# Edge case: no missing, not empty, but no valid times
		expect(empty_state.dirty?(non_empty)).to be == false
	end
end

describe Build::Files::State::FileTime do
	it "can inspect file time" do
		path = Build::Files::Path.new(__dir__)
		time = Time.now
		file_time = Build::Files::State::FileTime.new(path, time)
		
		inspect_str = file_time.inspect
		expect(inspect_str).to be(:include?, "FileTime")
	end
end
