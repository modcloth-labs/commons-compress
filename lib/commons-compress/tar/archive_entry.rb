module Commons
  module Compress
    module Tar
      class ArchiveEntry
        attr_reader :name

        def initialize(name)
          @name = name
        end
      end
    end
  end
end
