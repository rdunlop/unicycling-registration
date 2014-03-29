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
    before(:each) do
      @judge = FactoryGirl.create(:judge)
      FactoryGirl.create(:score, :judge => @judge)
    end
    it "cannot destroy the judge" do
      expect {
        @judge.destroy
      }.to change(Judge, :count).by(0)
    end
  end
end
