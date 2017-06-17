require 'spec_helper'

RSpec.describe JumpLimit::TripleFault do
  context "when there is a single fault" do
    let(:distance_attempts) { [FactoryGirl.create(:distance_attempt, fault: true)] }

    it "can attempt" do
      expect(subject.no_more_jumps?(distance_attempts)).to be_falsy
    end
  end

  context "when there are 2 faults at the same distance" do
    let(:distance_attempts) do
      [
        FactoryGirl.create(:distance_attempt, fault: true, distance: 12),
        FactoryGirl.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject.no_more_jumps?(distance_attempts)).to be_falsey
    end
  end

  context "when there are 3 faults at the same distance" do
    let(:distance_attempts) do
      [
        FactoryGirl.create(:distance_attempt, fault: true, distance: 12),
        FactoryGirl.create(:distance_attempt, fault: true, distance: 12),
        FactoryGirl.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject.no_more_jumps?(distance_attempts)).to be_truthy
    end
  end

  context "when there are 3 faults at different distances" do
    let(:distance_attempts) do
      [
        FactoryGirl.create(:distance_attempt, fault: true, distance: 11),
        FactoryGirl.create(:distance_attempt, fault: true, distance: 11),
        FactoryGirl.create(:distance_attempt, fault: true, distance: 12)
      ]
    end

    it "can attempt" do
      expect(subject.no_more_jumps?(distance_attempts)).to be_falsy
    end
  end
end
