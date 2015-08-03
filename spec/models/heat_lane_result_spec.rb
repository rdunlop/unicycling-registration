# == Schema Information
#
# Table name: heat_lane_results
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  heat           :integer          not null
#  lane           :integer          not null
#  status         :string           not null
#  minutes        :integer          not null
#  seconds        :integer          not null
#  thousands      :integer          not null
#  raw_data       :string
#  entered_at     :datetime         not null
#  entered_by_id  :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe HeatLaneResult do
  let(:hlr) { FactoryGirl.build_stubbed(:heat_lane_result) }

  it "has a valid factory" do
    expect(hlr.valid?).to eq(true)
  end

  describe "when disqualified" do
    let(:hlr) { FactoryGirl.build_stubbed(:heat_lane_result, :disqualified) }

    it "doesn't require time" do
      hlr.minutes = nil
      hlr.seconds = nil
      hlr.thousands = nil
      expect(hlr).to be_valid
    end
  end
end
