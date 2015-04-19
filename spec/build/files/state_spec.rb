# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'build/files'

module Build::Files::StateSpec
	describe Build::Files::State do
		let(:files) {Build::Files::Glob.new(__dir__, "*.rb")}
		
		it "should have no changes initially" do
			state = Build::Files::State.new(files)
			
			expect(state.update!).to be false
			
			expect(state.changed).to be == []
			expect(state.added).to be == []
			expect(state.removed).to be == []
			expect(state.missing).to be == []
		end
		
		it "should report missing files" do
			rebased_files = files.to_paths.rebase(File.join(__dir__, 'foo'))
			state = Build::Files::State.new(rebased_files)
			
			# Some changes were detected:
			expect(state.update!).to be true
			
			# Some files are missing:
			expect(state.missing).to_not be_empty
		end
		
		it "should not be confused by duplicates" do
			state = Build::Files::State.new(files + files)
			
			expect(state.update!).to be false
			
			expect(state.changed).to be == []
			expect(state.added).to be == []
			expect(state.removed).to be == []
			expect(state.missing).to be == []
		end
		
		it "should be clean with empty inputs or outputs" do
			empty = Build::Files::State.new(Build::Files::Paths::NONE)
			something = Build::Files::State.new(files)
			
			expect(Build::Files::State.dirty?(empty, something)).to be false
			expect(Build::Files::State.dirty?(something, empty)).to be false
		end
	end
end
