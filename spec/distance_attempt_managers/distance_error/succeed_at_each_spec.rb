require 'spec_helper'

RSpec.describe DistanceError::SucceedAtEach do
  describe "#acceptable_distance_error" do
    let(:current_attempt) { 10 }
    let(:previous_attempt) { double(fault?: previous_fault, distance: previous_distance) }
    let(:previous_attempts) { [previous_attempt].compact }
    let(:message) { described_class.new(previous_attempts, current_attempt).acceptable_distance_error }

    context "when there are no previous attempts" do
      let(:previous_attempt) { nil }

      it "returns no error" do
        expect(message).to be_nil
      end
    end

    context "when the previous distance was not a fault" do
      let(:previous_fault) { false }
      let(:previous_distance) { 5 }

      context "when the current attempt is equal to the previous distance" do
        let(:current_attempt) { previous_distance }

        it "returns a message describing the next distance" do
          expect(message).to eq("New Distance (5cm) must be greater than 5cm")
        end
      end

      context "when the current attempt is better than the previous" do
        let(:current_attempt) { previous_distance + 1 }
        it "returns no error" do
          expect(message).to be_nil
        end
      end
    end

    context "when the previous distance was a fault" do
      let(:previous_fault) { true }
      let(:previous_distance) { 5 }

      context "when the current distance is less than the previous" do
        let(:current_attempt) { previous_distance - 1 }

        it "returns an error message" do
          expect(message).to eq("Riders must successfully complete each distance before moving on to the next distance. Please complete 5cm")
        end
      end

      context "when the current distance is equal to the previous" do
        let(:current_attempt) { previous_distance }

        it "returns no error" do
          expect(message).to be_nil
        end
      end

      context "when the current distance is greater than the previous" do
        let(:current_attempt) { previous_distance + 1 }

        it "returns an error" do
          expect(message).to eq("Riders must successfully complete each distance before moving on to the next distance. Please complete 5cm")
        end
      end
    end
  end

  describe "#single_fault_message" do
    it "allows equal only value" do
      expect(described_class.single_fault_message(14)).to eq("Fault. Next Distance 14cm")
    end
  end
end
