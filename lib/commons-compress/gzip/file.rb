require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'buffered', 'file')

java_import org.apache.commons.compress.compressors.gzip.GzipCompressorInputStream
java_import org.apache.commons.compress.compressors.gzip.GzipCompressorOutputStream

module Commons
  module Compress
    module Gzip
      class File

        class << self
          def open(filename, modestr, &block)
            if block.nil?
              unsafe_open(filename, modestr)
            else
              auto(filename, modestr, &block)
            end
          end
          alias_method :new, :open

          private

          def parse(modestr)
            { read: modestr == 'r', write: modestr == 'w' }
          end

          def unsafe_open(filename, modestr)
            modes = parse(modestr)

            GzipStream.new(Buffered::File.open(filename, modestr), modes)
          end

          def auto(filename, modestr)
            begin
              gzip_stream = unsafe_open(filename, modestr)

              yield gzip_stream
            rescue Exception => e
              raise e
            ensure
              gzip_stream.close unless gzip_stream.nil?
            end
          end
        end

        class GzipStream
          attr_reader :wrapped_stream

          def initialize(underlying_stream, modes)
            @underlying_stream = underlying_stream
            @wrapped_stream = wrapped_stream_klass(modes).new(@underlying_stream.wrapped_stream)
          end

          def write(data, offset = 0)
            java_data = data.to_java_bytes

            wrapped_stream.write(java_data, offset, java_data.length)
          end

          def close
            wrapped_stream.close rescue nil
            underlying_stream.close rescue nil
          end

          private

          attr_reader :underlying_stream

          def wrapped_stream_klass(modes)
            modes[:read] ? GzipCompressorInputStream : GzipCompressorOutputStream
          end
        end
      end
    end
  end
end
