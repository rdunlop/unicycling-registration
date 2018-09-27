require 'spec_helper'

RSpec.describe JumpLimit::TripleFaultOrMaxAttempts12 do
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
      expect(subject).not_to be_no_more_jumps(distance_attempts)
    end
  end

  context "when there are 3 faults at the same distance" do
    let(:distance_attempts) do
      [
        FactoryBot.create(:distance_attempt, fault: true, distance: 12),
        FactoryBot.create(:distance_attempt, fault: true, distance: 12),
        FactoryBot.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject).to be_no_more_jumps(distance_attempts)
    end
  end

  context "when there are 3 faults at different distances" do
    let(:distance_attempts) do
      [
        FactoryBot.create(:distance_attempt, fault: true, distance: 11),
        FactoryBot.create(:distance_attempt, fault: true, distance: 11),
        FactoryBot.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject).not_to be_no_more_jumps(distance_attempts)
    end
  end

  context "when there are 12 attempts, but not triple fault" do
    let(:distance_attempts) do
      [
        FactoryBot.create(:distance_attempt, fault: true, distance: 1),
        FactoryBot.create(:distance_attempt, fault: true, distance: 2),
        FactoryBot.create(:distance_attempt, fault: true, distance: 3),
        FactoryBot.create(:distance_attempt, fault: true, distance: 4),
        FactoryBot.create(:distance_attempt, fault: true, distance: 5),
        FactoryBot.create(:distance_attempt, fault: true, distance: 6),
        FactoryBot.create(:distance_attempt, fault: true, distance: 7),
        FactoryBot.create(:distance_attempt, fault: true, distance: 8),
        FactoryBot.create(:distance_attempt, fault: true, distance: 9),
        FactoryBot.create(:distance_attempt, fault: true, distance: 10),
        FactoryBot.create(:distance_attempt, fault: true, distance: 11),
        FactoryBot.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "cannot attempt" do
      expect(subject).to be_no_more_jumps(distance_attempts)
    end
  end
end
