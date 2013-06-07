java_import java.io.FileInputStream
java_import java.io.FileOutputStream
java_import java.io.BufferedInputStream
java_import java.io.BufferedOutputStream

module Commons
  module Compress
    module Buffered
      class File

        class << self
          def open(filename, modestr, &block)
            modes = parse(modestr)

            if block.nil?
              unsafe_open(filename, modes)
            else
              auto(filename, modes, &block)
            end
          end
          alias_method :new, :open

          private

          def parse(modestr)
            { read: modestr == 'r', write: modestr == 'w' }
          end

          def unsafe_open(filename, modes)
            underlying_stream_klass = modes[:read] ? FileInputStream : FileOutputStream

            BufferedStream.new(underlying_stream_klass.new(filename), modes)
          end

          def auto(filename, modes)
            begin
              buffered_stream = unsafe_open(filename, modes)

              yield buffered_stream
            rescue Exception => e
              $stderr.puts "#{self.name} Error: #{e.message}"
              nil
            ensure
              buffered_stream.close unless buffered_stream.nil?
            end
          end
        end

        class BufferedStream
          attr_reader :wrapped_stream

          def initialize(underlying_stream, modes)
            @underlying_stream = underlying_stream
            @wrapped_stream = wrapped_stream_klass(modes).new(@underlying_stream)
          end

          def close
            wrapped_stream.close rescue nil
            underlying_stream.close rescue nil
          end

          private

          attr_reader :underlying_stream

          def wrapped_stream_klass(modes)
            modes[:read] ? BufferedInputStream : BufferedOutputStream
          end
        end
      end
    end
  end
end
