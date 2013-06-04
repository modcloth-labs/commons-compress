require 'bundler/gem_tasks'

require 'rspec'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = "--tty --color"
end

task :default => :spec

load 'commons-compress.gemspec'

