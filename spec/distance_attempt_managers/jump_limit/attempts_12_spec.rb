require 'spec_helper'

RSpec.describe JumpLimit::Attempts12 do
  context "when there are < 12 attempts" do
    let(:distance_attempts) { FactoryBot.create_list(:distance_attempt, 1) }

    it "can attempt" do
      expect(subject).not_to be_no_more_jumps(distance_attempts)
    end
  end

  context "when there are 12 attempts" do
    let(:distance_attempts) { FactoryBot.create_list(:distance_attempt, 12) }

    it "can attempt" do
      expect(subject).to be_no_more_jumps(distance_attempts)
    end
  end
end
