# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commons-compress/version'

Gem::Specification.new do |gem|
  gem.name          = "commons-compress"
  gem.version       = Commons::Compress::VERSION
  gem.authors       = ['Pat Bair', 'Luke Mommaerts']
  gem.email         = ['bi+commons-compress@modcloth.com']
  gem.description   = %q{Apache Commons Compress wrapper for JRuby.}
  gem.summary       = %q{Wraps Apache Commons Compress library for easy JRuby usage}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec'
end
