require 'spec_helper'

describe DismountScoreCalculator do
  let(:major_dismounts) { 0 }
  let(:minor_dismounts) { 0 }
  let(:score) { double(val_1: major_dismounts, val_2: minor_dismounts) }
  let(:resulting_score) { described_class.new(score, number_of_people).calculate }

  describe "for a single competitor" do
    let(:number_of_people) { 1 }

    it "has a perfect score" do
      expect(resulting_score).to eq(10)
    end

    describe "with a major dismount" do
      let(:major_dismounts) { 1 }
      it { expect(resulting_score).to eq(9) }
    end

    describe "with a minor dismount" do
      let(:minor_dismounts) { 1 }
      it { expect(resulting_score).to eq(9.5) }
    end

    describe "with a lot of major dismounts" do
      let(:major_dismounts) { 14 }

      it "has a zero score" do
        expect(resulting_score).to eq(0)
      end
    end
  end

  describe "with a pair of competitors" do
    let(:number_of_people) { 2 }

    it "has a perfect score" do
      expect(resulting_score).to eq(10)
    end

    describe "with a major dismount" do
      let(:major_dismounts) { 1 }
      it { expect(resulting_score).to eq(9) }
    end

    describe "with a minor dismount" do
      let(:minor_dismounts) { 1 }
      it { expect(resulting_score).to eq(9.5) }
    end
  end

  describe "for a group of 3" do
    let(:number_of_people) { 3 }

    describe "with 3 major" do
      let(:major_dismounts) { 3 }
      it { expect(resulting_score).to eq(9) }
    end

    describe "with 6 major" do
      let(:major_dismounts) { 6 }
      it { expect(resulting_score).to eq(8) }
    end

    describe "with 3 minor" do
      let(:minor_dismounts) { 3 }
      it { expect(resulting_score).to eq(9.5) }
    end

    describe "with an excessive number of dismounts" do
      let(:major_dismounts) { 20 }
      let(:minor_dismounts) { 25 }

      it { expect(resulting_score).to eq(0) }
    end

  end

  describe "for a group of 10" do
    let(:number_of_people) { 10 }

    it "has a perfect score" do
      expect(resulting_score).to eq(10)
    end

    describe "with 10 major dismount" do
      let(:major_dismounts) { 10 }

      it { expect(resulting_score).to eq(9) }
    end

    describe "with 10 major and 10 minor" do
      let(:major_dismounts) { 10 }
      let(:minor_dismounts) { 10 }

      it { expect(resulting_score).to eq(8.5) }
    end
  end
end
