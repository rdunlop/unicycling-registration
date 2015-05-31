require 'spec_helper'

describe FreestyleJudgePointsCalculator do
  let(:subject) { described_class.new }

  describe "ties" do
    # with a 2nd place, but tied
    let(:scores) { [5, 4, 4] }
    it "calculates the placing points for this tie score" do
      expect(subject.judged_points(scores, 4)).to eq(2.5)
    end
  end

  describe "with multiple scores" do
    let(:score_totals) { [0, 5, 10, 5] }
    let(:judged_place) { subject.judged_place(score_totals, score) }
    let(:judged_points) { subject.judged_points(score_totals, score) }

    describe "the lowest scoring competitor" do
      let(:score) { 0 }
      it "calculates the proper placement of each score" do
        expect(judged_place).to eq(4)
      end

      it "has the lowest (after ties) placing points" do
        expect(judged_points).to eq(4)
      end
    end

    describe "the highest scoring competitor" do
      let(:score) { 10 }
      it {
        expect(judged_place).to eq(1)
      }

      it "has 1 placing point (highest)" do
        expect(judged_points).to eq(1)
      end
    end

    describe "the tie in the middle" do
      let(:score) { 5 }
      it {
        expect(judged_place).to eq(2)
      }

      it "splits the placing points" do
        expect(judged_points).to eq(2.5)
      end
    end
  end
end
