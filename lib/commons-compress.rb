require 'commons-compress/version'
require 'commons-compress/init'

module Commons
  module Compress
    InvalidModeError = Class.new(StandardError)

    RDONLY = 0x1.freeze
    WRONLY = 0x2.freeze
  end
end
