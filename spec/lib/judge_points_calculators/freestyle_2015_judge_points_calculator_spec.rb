require 'spec_helper'

describe Freestyle_2015_JudgePointsCalculator do
  let(:subject) { described_class.new }

  describe "ties" do
    # with a 2nd place, but tied
    let(:scores) { [10, 5, 5] }
    it "calculates the placing points for this tie score" do
      expect(subject.judged_points(scores, 5)).to eq(25.0)
    end
  end

  describe "with very close fractions" do
    let(:score_totals) { [28.83, 29.9, 35] }

    it "rounds the percentages correctly" do
      expect(subject.judged_points(score_totals, 28.83)).to eq(30.76)
      expect(subject.judged_points(score_totals, 29.9)).to eq(31.90)
      expect(subject.judged_points(score_totals, 35)).to eq(37.34)
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
        expect(judged_points).to eq(0)
      end
    end

    describe "the highest scoring competitor" do
      let(:score) { 10 }
      it do
        expect(judged_place).to eq(1)
      end

      it "has 1 placing point (highest)" do
        expect(judged_points).to eq(50)
      end
    end

    describe "the tie in the middle" do
      let(:score) { 5 }
      it do
        expect(judged_place).to eq(2)
      end

      it "splits the placing points" do
        expect(judged_points).to eq(25)
      end
    end
  end
end
