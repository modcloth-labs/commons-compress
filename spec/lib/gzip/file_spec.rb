require 'commons-compress/gzip/file'

describe Commons::Compress::Gzip::File do
  let(:spec_dir) { File.join(File.expand_path(File.dirname(__FILE__)), '..', '..') }
  let(:test_file) { File.join(spec_dir, 'test.gz') }

  after(:each) {
    File.unlink(test_file) if File.exists?(test_file)
  }

  describe "writing a gzipped file" do
    it "should compress the contents of the file" do
      data = "hello".to_java.get_bytes

      described_class.open(test_file, 'w') do |gz|
        gz.write(data, 0, data.length)
      end

      File.exists?(test_file).should be_true
      Zlib::GzipReader.open(test_file) { |f| f.read.should == "hello" }
    end
  end
end
