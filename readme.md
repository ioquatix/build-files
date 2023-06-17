# Build::Files

Build::Files is a set of idiomatic classes for dealing with paths and monitoring directories. File paths are represented with both root and relative parts which makes copying directory structures intuitive.

[![Development Status](https://github.com/ioquatix/build-files/workflows/Test/badge.svg)](https://github.com/ioquatix/build-files/actions?workflow=Test)

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

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.
