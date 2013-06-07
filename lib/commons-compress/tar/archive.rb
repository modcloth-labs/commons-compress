require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'gzip', 'file')
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'buffered', 'file')
require_relative 'archive_entry'

java_import org.apache.commons.compress.archivers.tar.TarArchiveInputStream

module Commons
  module Compress
    module Tar
      class Archive

        class << self
          def open(filename, mode, &block)
            opts = parse(mode)

            if block.nil?
              unsafe_open(filename, opts[:gzip])
            else
              auto(filename, opts[:gzip], &block)
            end
          end
          alias_method :new, :open

          private

          def unsafe_open(filename, gzipped)
            TarStream.new(select_input(gzipped).new(filename, 'r'))
          end

          def auto(filename, gzipped)
            begin
              tar_stream = unsafe_open(filename, gzipped)

              yield OpenedArchive.new(tar_stream)
            rescue Exception => e
              $stderr.puts "#{self.name} Error: #{e.message}"
              nil
            ensure
              tar_stream.close unless tar_stream.nil?
            end
          end

          def select_input(gzipped)
            gzipped ? Gzip::File : Buffered::File
          end

          def parse(mode)
            { gzip: mode =~ /[rw]:g/ }
          end
        end

        class TarStream
          def initialize(underlying_stream)
            @underlying_stream = underlying_stream
            @wrapped_stream = TarArchiveInputStream.new(@underlying_stream.wrapped_stream)
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
