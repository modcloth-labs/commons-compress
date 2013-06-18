require_relative '../../../../lib/commons-compress'
require_relative '../../../../lib/commons-compress/buffered/file'

describe Commons::Compress::Buffered::File do
  describe "writing a buffered file" do
    context "an error occurs during file io" do
      let(:file) { double('file', close: nil) }

      before(:each) do
        described_class.stub(:unsafe_open).and_return(file)
      end

      it "should close the file" do
        file.should_receive(:close)

        begin
          described_class.open('foo.txt', 'r') do |f|
            raise IOError
          end
        rescue
        end
      end

      it "should re-raise the error" do
        expect do
          described_class.open('foo.txt', 'r') do |f|
            raise IOError
          end
        end.to raise_error
      end
    end
  end
end
