require 'spec_helper'

RSpec.describe JumpLimit::DoubleFault do
  context "when there is a single fault" do
    let(:distance_attempts) { [FactoryBot.create(:distance_attempt, fault: true)] }

    it "can attempt" do
      expect(subject).not_to be_no_more_jumps(distance_attempts)
    end
  end

  context "when there are 2 faults at the same distance" do
    let(:distance_attempts) do
      [
        FactoryBot.create(:distance_attempt, fault: true, distance: 12),
        FactoryBot.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject).to be_no_more_jumps(distance_attempts)
    end
  end

  context "when there are 2 faults at different distances" do
    let(:distance_attempts) do
      [
        FactoryBot.create(:distance_attempt, fault: true, distance: 11),
        FactoryBot.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject).not_to be_no_more_jumps(distance_attempts)
    end
  end
end
