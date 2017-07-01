require 'spec_helper'

describe Importers::HeatLaneLifImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:processor) do
    double(file_contents: ["line"],
           valid_file?: true,
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
      expect(importer.process(10, processor)).to be_truthy
    end.to change(HeatLaneResult, :count).by(1)
  end
end
