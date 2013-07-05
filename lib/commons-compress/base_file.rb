module Commons
  module Compress
    class BaseFile

      def self.open(filename, mode, &block)
        open_mode = parse(mode)

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

      def self.auto(filename, open_mode)
        begin
          stream = unsafe_open(filename, open_mode)

          yield stream
        rescue Exception => e
          raise e
        ensure
          stream.close unless stream.nil?
        end
      end

    end
  end
end
