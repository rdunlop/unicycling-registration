# == Schema Information
#
# Table name: judges
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  judge_type_id  :integer
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Judge do
  describe "when the judge has scores" do
    let(:judge) { FactoryGirl.build_stubbed(:judge) }
    let(:score) {FactoryGirl.create(:score, :judge => judge) }
    before(:each) do
      allow(judge).to receive(:scores).and_return([score])
    end

    it "cannot destroy the judge" do
      expect(judge.check_for_scores).to eq(false)
    end
  end

  describe "when the judge is a street judge" do
    let(:judge) { FactoryGirl.build_stubbed(:judge) }
    let(:street_score) {FactoryGirl.create(:street_score, :judge => judge) }
    before(:each) do
      allow(judge).to receive_message_chain(:competition, :event_class).and_return("Street")
      allow(judge).to receive(:street_scores).and_return([street_score])
    end

    it "returns the appropriate scores" do
      expect(judge.scores_by_event_class).to eq([street_score])
    end
  end
end
