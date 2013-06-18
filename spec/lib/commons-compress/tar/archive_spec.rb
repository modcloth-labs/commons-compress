require 'commons-compress'
require 'commons-compress/tar/archive'

describe Commons::Compress::Tar::Archive do
  let(:spec_dir) { File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..') }
  let(:first) { File.join(spec_dir, 'first.txt') }
  let(:second) { File.join(spec_dir, 'second.txt') }

  describe "extracting an uncompressed tarball" do
    let(:test_file) { File.join(spec_dir, 'test.tar') }

    it "should provide each entry in the tarball" do
      entries = []

      described_class.open(test_file, 'r') do |tar|
        tar.each_entry do |e|
          entries << e.name
        end
      end

      entries.should == ['first.txt', 'second.txt']
    end

    it "should return the names of the entries in the tarball" do
      entries = []
      described_class.open(test_file, 'r') do |tar|
        entries = tar.each_entry { |e| e }
      end

      entries.should == ['first.txt', 'second.txt']
    end

    it "should provide access to read from the archive" do
      file_data = []
      described_class.open(test_file, 'r') do |tar|
        tar.each_entry do |entry|
          tar.each_block do |data|
            file_data << data
          end
        end
      end

      file_data.should == ["first\n", "second\n"]
    end
  end

  describe "extracting a compressed tarball" do
    let(:test_file) { File.join(spec_dir, 'test.tgz') }

    it "should return the names of the entries in the tarball" do
      entries = []
      described_class.open(test_file, 'r:g') do |tar|
        entries = tar.each_entry { |e| e }
      end

      entries.should == ['first.txt', 'second.txt']
    end

    it "should provide each entry in the tarball" do
      entries = []

      described_class.open(test_file, 'r:g') do |tar|
        tar.each_entry do |e|
          entries << e.name
        end
      end

      entries.should == ['first.txt', 'second.txt']
    end

    it "should provide access to read from the archive" do
      file_data = []
      described_class.open(test_file, 'r:g') do |tar|
        tar.each_entry do |entry|
          tar.each_block do |data|
            file_data << data
          end
        end
      end

      file_data.should == ["first\n", "second\n"]
    end
  end

  describe "reading from a tarball" do
    context "an error occurs during file io" do
      let(:tar) { double('tar', close: nil) }

      before(:each) do
        described_class.stub(:unsafe_open).and_return(tar)
      end

      it "should close the file" do
        tar.should_receive(:close)

        begin
          described_class.open('foo.tar', 'r') do |t|
            raise IOError
          end
        rescue
        end
      end

      it "should re-raise the error" do
        expect do
          described_class.open('foo.tar', 'r') do |t|
            raise IOError
          end
        end.to raise_error
      end
    end
  end
end
