require 'spec_helper'

describe HeatLaneCalculator do
  let(:lanes) { 4 }
  let(:num_competitors) { 4 }
  let(:first_heat_number) { 1 }

  let(:subject) { described_class.new(lanes) }
  let(:result) { subject.heat_lane_list(num_competitors, first_heat_number) }

  describe "basic assignment" do
    it "fills the heat from the worst lane to the best" do
      expect(result).to eq([
                             { heat: 1, lane: 4 },
                             { heat: 1, lane: 3 },
                             { heat: 1, lane: 2 },
                             { heat: 1, lane: 1 }
                           ])
    end

    it "is valid" do
      expect(subject).to be_valid
    end

    context "with 2 heats of registrants" do
      let(:num_competitors) { 8 }

      it "fills the first heat, then the 2nd" do
        expect(result).to eq([
                               { heat: 1, lane: 4 },
                               { heat: 1, lane: 3 },
                               { heat: 1, lane: 2 },
                               { heat: 1, lane: 1 },
                               { heat: 2, lane: 4 },
                               { heat: 2, lane: 3 },
                               { heat: 2, lane: 2 },
                               { heat: 2, lane: 1 }
                             ])
      end
    end
  end

  describe "with 0 competitors" do
    let(:num_competitors) { 0 }

    it "returns an empty array" do
      expect(result).to eq([])
    end
  end

  describe "with only 3 competitors" do
    let(:num_competitors) { 3 }

    it "fills the best 3 positions" do
      expect(result).to eq([
                             { heat: 1, lane: 3 },
                             { heat: 1, lane: 2 },
                             { heat: 1, lane: 1 }
                           ])
    end
  end

  describe "when spread across multiple heats" do
    let(:num_competitors) { 9 }

    it "fills spreads the blanks equally" do
      expect(result).to eq([
                             { heat: 1, lane: 3 },
                             { heat: 1, lane: 2 },
                             { heat: 1, lane: 1 },

                             { heat: 2, lane: 3 },
                             { heat: 2, lane: 2 },
                             { heat: 2, lane: 1 },

                             { heat: 3, lane: 3 },
                             { heat: 3, lane: 2 },
                             { heat: 3, lane: 1 }
                           ])
    end
  end

  context "with a different starting heat_number" do
    let(:first_heat_number) { 30 }

    it "starts with heat 30" do
      expect(result).to eq([
                             { heat: 30, lane: 4 },
                             { heat: 30, lane: 3 },
                             { heat: 30, lane: 2 },
                             { heat: 30, lane: 1 }
                           ])
    end
  end

  context "with a different heat-lane order" do
    let(:result) do
      described_class.new(lanes, lane_assignment_order: [4, 5, 3, 6, 2, 7, 1])
                     .heat_lane_list(num_competitors, 1)
    end

    it "always assigns in the center of the track" do
      expect(result).to eq([
                             { heat: 1, lane: 6 },
                             { heat: 1, lane: 3 },
                             { heat: 1, lane: 5 },
                             { heat: 1, lane: 4 }
                           ])
    end
  end

  context "with a specified order with fewer entries than num lanes" do
    let(:subject) { described_class.new(5, lane_assignment_order: [1, 2, 3]) }

    it "is invalid" do
      expect(subject).not_to be_valid
    end

    it "has an error" do
      expect(subject.error).to eq("Unable to assign 5 lanes with only 3 positions specified")
    end
  end
end
