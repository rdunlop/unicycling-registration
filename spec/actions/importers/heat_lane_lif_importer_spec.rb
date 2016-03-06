require 'spec_helper'

describe HeatLaneLifImporter do
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

  it "can process lif files" do
    create_competitor(competition, 101, 10, 1)
    create_competitor(competition, 102, 10, 2)
    create_competitor(competition, 103, 10, 3)
    create_competitor(competition, 104, 10, 4)
    create_competitor(competition, 105, 10, 5)
    create_competitor(competition, 106, 10, 6)
    create_competitor(competition, 107, 10, 7)
    create_competitor(competition, 108, 10, 8)

    expect do
      expect(importer.process(sample_input, 10)).to be_truthy
    end.to change(HeatLaneResult, :count).by(8)
  end
end
