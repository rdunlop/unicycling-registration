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
end
