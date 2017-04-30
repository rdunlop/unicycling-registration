require 'spec_helper'

describe Importers::RecordCreators::HeatLaneResult do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:creator) { described_class.new(competition, admin_user, 10) }

  let(:row) do
    {
      lane: "1",
      minutes: 2,
      seconds: 35,
      thousands: 190,
      status: "active"
    }
  end

  it "can process lif files" do
    expect do
      expect(creator.save(row, "raw")).to be_truthy
    end.to change(HeatLaneResult, :count).by(1)
  end
end
