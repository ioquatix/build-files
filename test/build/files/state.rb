# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2023, by Samuel Williams.

require 'build/files'
require 'build/files/state'

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
	
	it "should report missing files" do
		rebased_files = files.to_paths.rebase(File.join(__dir__, 'foo'))
		state = Build::Files::State.new(rebased_files)
		
		# Some changes were detected:
		expect(state.update!).to be == true
		
		# Some files are missing:
		expect(state.missing).not.to be(:empty?)
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
		@temporary_files = Build::Files::Paths.directory(__dir__, ['a'])
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
end
