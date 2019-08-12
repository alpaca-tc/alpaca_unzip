# frozen_string_literal: true

RSpec.describe AlpacaUnzip::Zip do
  describe 'InstanceMethods' do
    describe '#local_files' do
      subject { instance.local_files }

      let(:instance) do
        described_class.load_file(path)
      end

      let(:path) do
        fixture_path('single_file.zip')
      end

      it 'returns local_files' do
        is_expected.to be_all(be_a(AlpacaUnzip::LocalFile))

        local_filenames = subject.map(&:header).map(&:filename)
        expect(local_filenames).to eq(['file'])
      end
    end

    describe '#central_directories' do
      subject { instance.central_directories }

      let(:instance) do
        described_class.load_file(path)
      end

      let(:path) do
        fixture_path('single_file.zip')
      end

      it 'returns central_directories' do
        is_expected.to be_all(be_a(AlpacaUnzip::CentralDirectory))
      end
    end

    describe '#end_of_central_directory' do
      subject { instance.end_of_central_directory }

      let(:instance) do
        described_class.load_file(path)
      end

      let(:path) do
        fixture_path('single_file.zip')
      end

      it 'returns end_of_central_directory' do
        is_expected.to be_a(AlpacaUnzip::EndOfCentralDirectory)
      end
    end
  end
end
