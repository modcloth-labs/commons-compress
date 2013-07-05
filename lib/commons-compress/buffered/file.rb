module Commons
  module Compress
    module Buffered
      class File

        RDONLY = 0x1.freeze
        WRONLY = 0x2.freeze

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
          when 'r' then RDONLY
          when 'w' then WRONLY
          end
        end

        def self.unsafe_open(filename, open_mode)
          case open_mode
          when RDONLY then unsafe_open_read(filename)
          when WRONLY then unsafe_open_write(filename)
          end
        end

        def self.auto(filename, modes)
          begin
            buffered_stream = unsafe_open(filename, modes)

            yield buffered_stream
          rescue Exception => e
            raise e
          ensure
            buffered_stream.close unless buffered_stream.nil?
          end
        end

        def self.unsafe_open_read(filename)
          BufferedStream.new(java.io.FileInputStream.new(filename), RDONLY)
        end

        def self.unsafe_open_write(filename)
          BufferedStream.new(java.io.FileOutputStream.new(filename), WRONLY)
        end

        class BufferedStream
          attr_reader :wrapped_stream

          def initialize(underlying_stream, open_mode)
            @underlying_stream = underlying_stream
            @wrapped_stream = open(open_mode)
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
            java.io.BufferedInputStream.new(underlying_stream)
          end

          def open_write
            java.io.BufferedOutputStream.new(underlying_stream)
          end
        end
      end
    end
  end
end
