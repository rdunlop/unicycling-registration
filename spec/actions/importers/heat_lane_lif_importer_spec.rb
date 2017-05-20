require 'spec_helper'

describe Importers::HeatLaneLifImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:test_file) { fixture_path + '/800m14.lif' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }
  let(:processor) do
    double(extract_file: ["line"],
           process_row: {
             lane: "1",
             minutes: 2,
             seconds: 35,
             thousands: 190,
             status: "active"
           })
  end

  it "can process lif files" do
    expect do
      expect(importer.process(sample_input, 10, processor)).to be_truthy
    end.to change(HeatLaneResult, :count).by(1)
  end
end
