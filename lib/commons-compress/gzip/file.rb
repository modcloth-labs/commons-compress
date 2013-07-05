require_relative '../buffered/file'

module Commons
  module Compress
    module Gzip
      class File

        def self.open(filename, modestr, &block)
          open_mode = parse(modestr)

          if block.nil?
            unsafe_open(filename, open_mode)
          else
            auto(filename, open_mode, &block)
          end
        end

        class << self
          alias_method :new, :open
        end

        private

        def self.parse(modestr)
          case modestr
          when RDONLY, WRONLY then modestr
          when 'r' then RDONLY
          when 'w' then WRONLY
          else raise InvalidModeError, "illegal access mode #{modestr}"
          end
        end

        def self.unsafe_open(filename, open_mode)
          GzipStream.new(Buffered::File.open(filename, open_mode), open_mode)
        end

        def self.auto(filename, open_mode)
          begin
            gzip_stream = unsafe_open(filename, open_mode)

            yield gzip_stream
          rescue Exception => e
            raise e
          ensure
            gzip_stream.close unless gzip_stream.nil?
          end
        end

        class GzipStream
          attr_reader :wrapped_stream

          def initialize(underlying_stream, open_mode)
            @underlying_stream = underlying_stream
            @wrapped_stream = open(open_mode)
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

          def open(open_mode)
            case open_mode
            when RDONLY then open_read
            when WRONLY then open_write
            end
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
