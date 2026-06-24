# == Schema Information
#
# Table name: trials_results
#
#  id            :bigint           not null, primary key
#  competitor_id :integer          not null
#  points        :integer          not null
#  minutes       :integer          not null
#  seconds       :integer          not null
#  details       :string
#  entered_at    :datetime         not null
#  entered_by_id :integer          not null
#  status        :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_trials_results_on_competitor_id  (competitor_id) UNIQUE
#

require 'spec_helper'

describe TrialsResult do
  describe "set_details_if_empty" do
    it "uses details if explicitly set" do
      result = FactoryBot.create(:trials_result, points: 42, minutes: 57, seconds: 28, details: "42 points, 1st place")
      expect(result.details).to eq("42 points, 1st place")
    end

    it "sets details if not explicitly set" do
      result = FactoryBot.create(:trials_result, points: 42, minutes: 57, seconds: 28, details: nil)
      expect(result.details).to eq("42 pts (57m 28s)")
    end
  end
end
