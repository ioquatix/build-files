# Copyright, 2014, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'fileutils'

module Build
	module Files
		class Path
			def open(mode, &block)
				File.open(self, mode, &block)
			end
			
			def read(mode = File::RDONLY)
				open(mode) do |file|
					file.read
				end
			end
			
			def write(buffer, mode = File::CREAT|File::TRUNC|File::WRONLY)
				open(mode) do |file|
					file.write(buffer)
				end
			end
			
			def touch
				FileUtils.touch self
			end
			
			def exist?
				File.exist? self
			end
			
			def directory?
				File.directory? self
			end
			
			def modified_time
				File.mtime self
			end
			
			alias mtime modified_time
			
			def create
				FileUtils.mkpath self
			end
			
			alias mkpath create
			
			def delete
				FileUtils.rm_rf self
			end
			
			alias rmpath delete
		end
	end
end
