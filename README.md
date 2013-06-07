# commons-compress

A simple jruby wrapper around Apache commons-compress library. Attempts
to give an easy ruby-like API for programmers with ruby's file
libraries.

## Installation

Add this line to your application's Gemfile:

    gem 'commons-compress' then execute:

    $ bundle

Or install it yourself as:

    $ gem install commons-compress'

## Usage

```ruby
Commons::Compress::Tar::Archive.open('foo.tgz', 'r:g') do |tar|
  tar.each_entry do |entry|
    tar.each_block do |data|
      puts entry.name
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
