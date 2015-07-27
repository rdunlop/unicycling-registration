require 'spec_helper'

describe SumScoreCalculator do
  let(:score) { FactoryGirl.build(:score, val_1: val_1, val_2: val_2, val_3: val_3, val_4: val_4) }
  let(:resulting_score) { described_class.new(score).calculate }

  describe "with 10's all around" do
    let(:val_1) { 10 }
    let(:val_2) { 10 }
    let(:val_3) { 10 }
    let(:val_4) { 10 }

    it { expect(resulting_score).to eq(40) }
  end

  describe "with lower scores" do
    let(:val_1) { 10 }
    let(:val_2) { 7 }
    let(:val_3) { 5 }
    let(:val_4) { 0 }

    it { expect(resulting_score).to eq(22) }
  end
end
