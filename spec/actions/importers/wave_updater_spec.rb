require 'spec_helper'

describe Importers::WaveUpdater do
  let(:competition) { FactoryGirl.create(:timed_competition) }

  describe "update waves" do
    let(:wave_data_file_name) { fixture_path + '/sample_wave_assignments.txt' }
    let(:wave_data_file) { Rack::Test::UploadedFile.new(wave_data_file_name, "text/plain") }
    let!(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition, bib_number: 101) }

    let(:processor) do
      double(extract_file: ["line"],
             process_row: {
               bib_number: "101",
               wave: "1"
             })
    end

    it "updates the waves" do
      expect(competitor1.wave).to be_nil

      expect(described_class.new(competition, nil).process(wave_data_file, processor)).to be_truthy

      expect(competitor1.reload.wave).to eq(1)
    end
  end
end
