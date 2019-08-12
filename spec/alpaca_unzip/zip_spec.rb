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
  end
end
