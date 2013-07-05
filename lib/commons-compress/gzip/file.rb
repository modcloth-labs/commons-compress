require_relative '../base_file'
require_relative '../buffered/file'

module Commons
  module Compress
    module Gzip
      class File < BaseFile

        private

        def self.unsafe_open(filename, open_mode)
          GzipStream.new(Buffered::File.open(filename, open_mode), open_mode)
        end

        class GzipStream < BaseStream
          def write(data, offset = 0)
            java_data = data.to_java_bytes

            wrapped_stream.write(java_data, offset, java_data.length)
          end

          def open_read
            org.apache.commons.compress.compressors.gzip.
              GzipCompressorInputStream.new(underlying_stream.wrapped_stream)
          end

          def open_write
            org.apache.commons.compress.compressors.gzip.
              GzipCompressorOutputStream.new(underlying_stream.wrapped_stream)
          end
        end
      end
    end
  end
end
