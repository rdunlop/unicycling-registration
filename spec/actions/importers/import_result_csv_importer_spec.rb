require 'spec_helper'

describe ImportResultCsvImporter do
  def create_competitor(competition, bib_number, heat, lane)
    competitor = FactoryGirl.create(:event_competitor, competition: competition)
    reg = competitor.members.first.registrant
    reg.update_attribute(:bib_number, bib_number)
    if heat && lane
      FactoryGirl.create(:lane_assignment, competition: competition, competitor: competitor, heat: heat, lane: lane)
    end
  end

  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:test_file) { fixture_path + '/800m14.lif' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  describe "when importing CSV data" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101.txt' }

    it "creates a competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process(sample_input, false)
      end.to change(ImportResult, :count).by(1)

      expect(ImportResult.count).to eq(1)
      ir = ImportResult.first
      expect(ir.bib_number).to eq(101)
      expect(ir.minutes).to eq(1)
      expect(ir.seconds).to eq(2)
      expect(ir.thousands).to eq(300)
      expect(ir.disqualified?).to eq(false)
      expect(ir.competition).to eq(competition)
      expect(ir.is_start_time).to eq(false)
    end

    it "can import start times" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process(sample_input, true)
      end.to change(ImportResult, :count).by(1)

      expect(ImportResult.count).to eq(1)
      ir = ImportResult.first
      expect(ir.is_start_time).to eq(true)
    end
  end

  describe "when importing dq-results" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101_dq.txt' }

    it "creates a dq competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process(sample_input, true)
      end.to change(ImportResult, :count).by(1)

      expect(ImportResult.count).to eq(1)
      expect(ImportResult.first.disqualified?).to eq(true)
    end
  end
end
