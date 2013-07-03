# commons-compress

[![Build Status](https://travis-ci.org/modcloth-labs/commons-compress.png?branch=master)](https://travis-ci.org/modcloth-labs/commons-compress)

A simple JRuby wrapper around the Apache [commons-compress](http://commons.apache.org/proper/commons-compress/) library.
Attempts to give a ruby-like API for programmers familiar with ruby's file
libraries.

## Installation

Add this line to your application's Gemfile:

    gem 'commons-compress', github: 'modcloth-labs/commons-compress'

then execute:

    $ bundle

## Usage

```ruby
Commons::Compress::Tar::Archive.open('foo.tgz', 'r:g') do |tar|
  tar.each_entry do |entry|
    puts entry.name

    tar.each_block do |data|
      puts data
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
