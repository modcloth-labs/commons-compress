require 'commons-compress'
require 'commons-compress/gzip/file'
require 'zlib'

describe Commons::Compress::Gzip::File do
  let(:spec_dir) { File.join(File.expand_path(File.dirname(__FILE__)), '../../..') }
  let(:test_file) { File.join(spec_dir, 'test.gz') }

  after(:each) {
    File.unlink(test_file) if File.exists?(test_file)
  }

  describe "writing a gzipped file" do
    it "should compress the contents of the file" do
      described_class.open(test_file, 'w') do |gz|
        gz.write("hello")
      end

      File.exists?(test_file).should be_true
      Zlib::GzipReader.open(test_file) { |f| f.read.should == "hello" }
    end

    context "an error occurs during file io" do
      let(:gzip) { double('gzip', close: nil) }

      before(:each) do
        described_class.stub(:unsafe_open).and_return(gzip)
      end

      it "should close the file" do
        gzip.should_receive(:close)

        begin
          described_class.open('foo.gz', 'r') do |g|
            raise IOError
          end
        rescue
        end
      end

      it "should re-raise the error" do
        expect do
          described_class.open('foo.gz', 'r') do |g|
            raise IOError
          end
        end.to raise_error
      end
    end
  end
end
