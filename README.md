# Build::Files

Build::Files is a set of idiomatic classes for dealing with paths and monitoring directories. File paths are represented with both root and relative parts which makes copying directory structures intuitive.

[![Development Status](https://github.com/ioquatix/build-files/workflows/Development/badge.svg)](https://github.com/ioquatix/build-files/actions?workflow=Development)

## Installation

Add this line to your application's Gemfile:

    gem 'build-files'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install build-files

## Usage

The basic structure is the `Path`. Paths are stored with a root and relative part. By default, if no root is specified, it is the `dirname` part.

    require 'build/files'
    
    path = Build::Files::Path("/foo/bar/baz")
    => "/foo/bar"/"baz"
    
    > path.root
    => "/foo/bar"
    > path.relative_path
    => "baz"

Paths can be coerced to strings and thus are suitable arguments to `exec`/`system` functions.

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request

## License

Released under the MIT license.

Copyright, 2014, by [Samuel G. D. Williams](https://www.codeotaku.com).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
