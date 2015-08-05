require 'spec_helper'

describe CompetitorOrderer do
  describe "competitors without tie break scores" do
    before do
      @comp1 = double(:competitor, comparable_score: 1, comparable_tie_break_score: nil)
      @comp2 = double(:competitor, comparable_score: 2, comparable_tie_break_score: nil)
      @comp3 = double(:competitor, comparable_score: 3, comparable_tie_break_score: nil)
      @comp4 = double(:competitor, comparable_score: 4, comparable_tie_break_score: nil)
    end

    subject { described_class.new([@comp1, @comp2, @comp3, @comp4]).sort }

    it "sorts the competitors by lowest score to highest" do
      expect(subject).to eq([@comp1, @comp2, @comp3, @comp4])
    end
  end

  describe "competitors with nil scores" do
    before do
      @comp1 = double(:competitor, comparable_score: nil, comparable_tie_break_score: nil)
      @comp2 = double(:competitor, comparable_score: 2, comparable_tie_break_score: nil)
      @comp3 = double(:competitor, comparable_score: 3, comparable_tie_break_score: nil)
      @comp4 = double(:competitor, comparable_score: 4, comparable_tie_break_score: nil)
    end

    subject { described_class.new([@comp1, @comp2, @comp3, @comp4]).sort }

    it "sorts the competitors by lowest score to highest" do
      expect(subject).to eq([@comp2, @comp3, @comp4, @comp1])
    end
  end

  describe "competitors without scores" do
    before do
      @comp1 = double(:competitor, comparable_score: Float::NAN, comparable_tie_break_score: nil)
      @comp2 = double(:competitor, comparable_score: 2, comparable_tie_break_score: nil)
      @comp3 = double(:competitor, comparable_score: 3, comparable_tie_break_score: nil)
      @comp4 = double(:competitor, comparable_score: 4, comparable_tie_break_score: nil)
    end

    subject { described_class.new([@comp1, @comp2, @comp3, @comp4]).sort }

    it "sorts the competitors by lowest score to highest" do
      expect(subject).to eq([@comp2, @comp3, @comp4, @comp1])
    end
  end

  describe "competitors with tie break scores" do
    before do
      @comp1 = double(:competitor, comparable_score: 1, comparable_tie_break_score: 1)
      @comp2 = double(:competitor, comparable_score: 2, comparable_tie_break_score: 2)
      @comp3 = double(:competitor, comparable_score: 2, comparable_tie_break_score: 1)
      @comp4 = double(:competitor, comparable_score: 4, comparable_tie_break_score: 3)
    end

    subject { described_class.new([@comp1, @comp2, @comp3, @comp4]).sort }

    it "sorts the competitors by tie break places" do
      expect(subject).to eq([@comp1, @comp3, @comp2, @comp4])
    end
  end

  describe "when calculating the placing of higher-points-is-better races" do
    before :each do
      @comp1 = double(:competitor, comparable_score: 1, comparable_tie_break_score: nil)
      @comp2 = double(:competitor, comparable_score: 2, comparable_tie_break_score: nil)
      @comp3 = double(:competitor, comparable_score: 3, comparable_tie_break_score: nil)
      @comp4 = double(:competitor, comparable_score: 4, comparable_tie_break_score: nil)
    end

    subject { described_class.new([@comp1, @comp2, @comp3, @comp4], false).sort }

    it "sets the competitor places to the opposite of the points" do
      expect(subject).to eq([@comp4, @comp3, @comp2, @comp1])
    end
  end
end
