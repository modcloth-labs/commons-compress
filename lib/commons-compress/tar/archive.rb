require_relative '../base_file'
require_relative '../buffered/file'
require_relative '../gzip/file'

require_relative 'archive_entry'

module Commons
  module Compress
    module Tar
      class Archive < BaseFile

        def self.open(filename, mode, &block)
          open_mode, gzipped = parse(mode)

          if block.nil?
            unsafe_open(filename, open_mode, gzipped)
          else
            auto(filename, open_mode, gzipped, &block)
          end
        end

        private

        def self.unsafe_open(filename, open_mode, gzipped)
          if gzipped
            open_gzipped(filename, open_mode)
          else
            open_buffered(filename, open_mode)
          end
        end

        def self.auto(filename, open_mode, gzipped)
          begin
            tar_stream = unsafe_open(filename, open_mode, gzipped)

            yield OpenedArchive.new(tar_stream)
          rescue Exception => e
            raise e
          ensure
            tar_stream.close unless tar_stream.nil?
          end
        end

        def self.open_gzipped(filename, open_mode)
          TarStream.new(Gzip::File.new(filename, open_mode), open_mode)
        end

        def self.open_buffered(filename, open_mode)
          TarStream.new(Buffered::File.new(filename, open_mode), open_mode)
        end

        def self.parse(modestr)
          open_modestr, gzipped = modestr.split(':')

          open_mode = case open_modestr
          when 'r' then RDONLY
          else raise InvalidModeError, "illegal access mode #{modestr}"
          end

          [open_mode, gzipped]
        end

        class TarStream
          def initialize(underlying_stream, open_mode)
            @underlying_stream = underlying_stream
            @wrapped_stream = open(open_mode)
          end

          def next_entry
            wrapped_stream.get_next_entry
          end

          def read(buffer, offset, length)
            wrapped_stream.read(buffer, offset, length)
          end

          def close
            wrapped_stream.close rescue nil
            underlying_stream.close rescue nil
          end

          private

          attr_reader :wrapped_stream, :underlying_stream

          def open(open_mode)
            case open_mode
            when RDONLY then open_read
            end
          end

          def open_read
            org.apache.commons.compress.archivers.tar.
              TarArchiveInputStream.new(underlying_stream.wrapped_stream)
          end
        end

        class OpenedArchive
          def initialize(tar_stream)
            @tar_stream = tar_stream
          end

          def each_entry
            [].tap do |entries|
              while entry = tar_stream.next_entry
                yield Tar::ArchiveEntry.new(entry.get_name)

                entries << entry.get_name
              end
            end
          end

          def each_block(size = 4096)
            count, data = 0, Java::byte[size].new

            while (count = tar_stream.read(data, 0, size)) != -1
              yield String.from_java_bytes(data)[0...count]
            end
          end

          private

          attr_reader :tar_stream
        end
      end
    end
  end
end
