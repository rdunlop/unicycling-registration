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
