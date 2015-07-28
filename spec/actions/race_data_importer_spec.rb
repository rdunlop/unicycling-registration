require 'spec_helper'

def create_competitor(competition, _bib_number, heat, lane)
  reg = FactoryGirl.create(:registrant, bib_number: 101)
  competitor = FactoryGirl.create(:event_competitor, competition: competition)
  FactoryGirl.create(:member, competitor: competitor, registrant: reg)
  if heat && lane
    FactoryGirl.create(:lane_assignment, competition: competition, competitor: competitor, heat: heat, lane: lane)
  end
end

describe RaceDataImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { RaceDataImporter.new(competition, admin_user) }

  let(:test_file) { fixture_path + '/800m14.lif' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  describe "when importing CSV data" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101.txt' }

    it "creates a competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process_csv(sample_input, false)
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
        importer.process_csv(sample_input, true)
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
        importer.process_csv(sample_input, true)
      end.to change(ImportResult, :count).by(1)

      expect(ImportResult.count).to eq(1)
      expect(ImportResult.first.disqualified?).to eq(true)
    end
  end

  it "can process lif files" do
    create_competitor(competition, 101, 10, 1)
    create_competitor(competition, 102, 10, 2)
    create_competitor(competition, 103, 10, 3)
    create_competitor(competition, 104, 10, 4)
    create_competitor(competition, 105, 10, 5)
    create_competitor(competition, 106, 10, 6)
    create_competitor(competition, 107, 10, 7)
    create_competitor(competition, 108, 10, 8)

    importer = RaceDataImporter.new(competition, admin_user)
    expect do
      expect(importer.process_lif(sample_input, 10)).to be_truthy
    end.to change(HeatLaneResult, :count).by(8)
  end

  it "gives good error message upon failure" do
    create_competitor(competition, 101, 10, 1)
    # missing
    create_competitor(competition, 103, 10, 3)
    create_competitor(competition, 104, 10, 4)
    create_competitor(competition, 105, 10, 5)
    create_competitor(competition, 106, 10, 6)
    create_competitor(competition, 107, 10, 7)
    create_competitor(competition, 108, 10, 8)

    expect do
      expect(importer.process_lif(sample_input, 10)).to be_truthy
    end.to change(HeatLaneResult, :count).by(8)

    expect(importer.errors).to_not be_nil
  end
end
