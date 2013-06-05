require 'commons-compress/file_extractor'
require 'zlib'

describe Commons::Compress::FileExtractor do
  let(:test_dir) { File.join(File.expand_path(File.dirname(__FILE__)), '..', '..') }
  let(:test_file) { File.join(test_dir, 'test.tgz') }
  let(:first) { File.join(test_dir, 'first.gz') }
  let(:second) { File.join(test_dir, 'second.gz') }

  let(:extractor) { described_class.new(test_file) }

  before(:each) do
    extractor.extract_and_compress
  end

  after(:each) do
    [first, second].each { |f| File.unlink(f) if File.exist?(f) }
  end

  it "should extract a gzipped tarball into individual files" do
    (File.exists?(first) && File.exist?(second)).should be_true
  end

  it "should re-compress the extracted files while writing them" do
    Zlib::GzipReader.open(first) { |f| f.read.should == "first\n" }
    Zlib::GzipReader.open(second) { |f| f.read.should == "second\n" }
  end

  it "should preserve the source file during extraction" do
    File.exists?(test_file).should be_true
  end
end
