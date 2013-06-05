require 'commons-compress'

java_import java.io.FileInputStream
java_import java.io.FileOutputStream
java_import java.io.BufferedInputStream
java_import java.io.BufferedOutputStream

java_import org.apache.commons.compress.archivers.tar.TarArchiveEntry
java_import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
java_import org.apache.commons.compress.compressors.gzip.GzipCompressorInputStream
java_import org.apache.commons.compress.compressors.gzip.GzipCompressorOutputStream

module Commons
  module Compress
    FileExtractionError = Class.new(StandardError)

    class FileExtractor
      BUFF_SIZE = 4096

      def initialize(local_file)
        @local_file = local_file
      end

      def extract_and_compress
        with_tar_gz_stream do |tar_in|
          with_entry(tar_in) do |entry, gz_out|
            count, data = 0, Java::byte[BUFF_SIZE].new

            while (count = tar_in.read(data, 0, BUFF_SIZE)) != -1
              gz_out.write(data, 0, count)
            end
          end
        end
      end

      protected

      attr_reader :local_file

      def with_tar_gz_stream
        begin
          file_in = FileInputStream.new(local_file)
          buff_in = BufferedInputStream.new(file_in)
          gzip_in = GzipCompressorInputStream.new(buff_in)
          tar_in = TarArchiveInputStream.new(gzip_in)

          yield tar_in
        rescue Exception => e
          raise FileExtractionError, "Error extracting file #{e.message}"
        ensure
          close_all(tar_in, gzip_in, buff_in, file_in)
        end
      end

      def with_entry(tar_in)
        begin
          while entry = tar_in.get_next_entry
            file_out = FileOutputStream.new(output_entry_path(entry.get_name))
            buff_out = BufferedOutputStream.new(file_out)
            gzip_out = GzipCompressorOutputStream.new(buff_out)

            yield entry, gzip_out
            close_all(gzip_out, buff_out, file_out)
          end
        rescue Exception => e
          raise FileExtractionError, "Error writing extracted file #{e.message}"
        ensure
          close_all(gzip_out, buff_out, file_out)
        end
     end

      def output_entry_path(entry_name)
        File.join(File.dirname(local_file), File.basename(entry_name, '.*')) + '.gz'
      end

      def close_all(*args)
        args.each { |i| i.close unless i.nil? }
      end
    end
  end
end
