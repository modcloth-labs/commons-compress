require 'commons-compress/file_extractor'

describe Commons::Compress::FileExtractor do
  let(:test_dir) { File.join(File.expand_path(File.dirname(__FILE__)), '..', '..') }
  let(:test_file) { File.join(test_dir, 'test.tgz') }
  let(:first) { File.join(test_dir, 'first.txt') }
  let(:second) { File.join(test_dir, 'second.txt') }

  let(:extractor) { described_class.new(test_file) }

  before(:each) do
    extractor.extract
  end

  after(:each) do
    [first, second].each { |f| File.unlink(f) if File.exist?(f) }
  end

  it "should extract a gzipped tarball into individual files" do
    (File.exists?(first) && File.exist?(second)).should be_true
  end

  it "should extract a gzipped tarball into the correct input files" do
    File.open(first, 'r') { |f| f.readline.should == "first\n" }
    File.open(second, 'r') { |f| f.readline.should == "second\n" }
  end

  it "should preserve the source file during extraction" do
    File.exists?(test_file).should be_true
  end
end
