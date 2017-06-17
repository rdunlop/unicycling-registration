require 'spec_helper'

RSpec.describe JumpLimit::Attempts12 do
  context "when there are < 12 attempts" do
    let(:distance_attempts) { FactoryGirl.create_list(:distance_attempt, 1) }

    it "can attempt" do
      expect(subject.no_more_jumps?(distance_attempts)).to be_falsy
    end
  end

  context "when there are 12 attempts" do
    let(:distance_attempts) { FactoryGirl.create_list(:distance_attempt, 12) }

    it "can attempt" do
      expect(subject.no_more_jumps?(distance_attempts)).to be_truthy
    end
  end
end
