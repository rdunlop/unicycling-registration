require 'spec_helper'

shared_context "given rider has scores" do |options = {}|
  before :each do
    comp = FactoryGirl.build_stubbed(:event_competitor)
    scores = []
    options[:presentation_scores].each do |val|
      score = FactoryGirl.build_stubbed(:score)
      allow(score).to receive(:judge_type).and_return(pres_type)
      allow(score).to receive(:placing_points).and_return(val)
      scores << score
    end
    options[:technical_scores].each do |val|
      score = FactoryGirl.build_stubbed(:score)
      allow(score).to receive(:judge_type).and_return(tech_type)
      allow(score).to receive(:placing_points).and_return(val)
      scores << score
    end
    allow(comp).to receive(:scores).and_return(scores)
    allow(comp).to receive(:competition).and_return(competition)
    competitors[options[:name]] = comp
  end
end

def comp(competitor_name)
  competitors[competitor_name]
end

describe ArtisticScoreCalculator do
  let(:subject) { ArtisticScoreCalculator.new(competition, true) }
  let(:competitors) { {} }
  let(:competition) { FactoryGirl.build_stubbed(:competition) }
  let(:pres_type) { FactoryGirl.build_stubbed(:judge_type, :name => "Presentation") }
  let(:tech_type) { FactoryGirl.build_stubbed(:judge_type, :name => "Technical") }

  describe "when eliminating scores" do
    include_context "given rider has scores", name: "A", presentation_scores: [4,4,4,4], technical_scores: [4,4,4,4]
    include_context "given rider has scores", name: "B", presentation_scores: [1,1,1,1], technical_scores: [1,1,1,1]
    include_context "given rider has scores", name: "C", presentation_scores: [2,2,3,3], technical_scores: [2,3,2,3]
    include_context "given rider has scores", name: "D", presentation_scores: [3,3,2,2], technical_scores: [3,2,3,2]

    before :each do
      allow(competition).to receive(:competitors).and_return(competitors.values)
      allow(competition).to receive(:judge_types).and_return([pres_type, tech_type])
      allow(JudgeType).to receive(:find_by_name).with("Technical").and_return(tech_type)
    end

    it "calculates the scores for A" do
      expect(subject.total_points(comp("A"))).to eq(24)
      expect(subject.total_points(comp("A"), pres_type)).to eq(8)
      expect(subject.total_points(comp("A"), tech_type)).to eq(8)
    end

    it "calculates the scores for B" do
      expect(subject.total_points(comp("B"))).to eq(6)
      expect(subject.total_points(comp("B"), pres_type)).to eq(2)
      expect(subject.total_points(comp("B"), tech_type)).to eq(2)
    end

    it "calculates places" do
      expect(subject.place(comp("A"))).to eq(4)
      expect(subject.place(comp("B"))).to eq(1)
      expect(subject.place(comp("C"))).to eq(2)
      expect(subject.place(comp("D"))).to eq(2)
    end
  end

  describe "when testing ties" do
    include_context "given rider has scores", name: "A", presentation_scores: [2,1,1], technical_scores: [3,2,2]
    include_context "given rider has scores", name: "B", presentation_scores: [1,2,3], technical_scores: [1,1,3]
    include_context "given rider has scores", name: "C", presentation_scores: [3,3,2], technical_scores: [2,3,1]

    before :each do
      allow(competition).to receive(:competitors).and_return(competitors.values)
      allow(competition).to receive(:judge_types).and_return([pres_type, tech_type])
      allow(JudgeType).to receive(:find_by_name).with("Technical").and_return(tech_type)
    end
    it "calculates the scores for A" do
      expect(subject.total_points(comp("A"))).to eq(7)
      expect(subject.total_points(comp("A"), pres_type)).to eq(1)
      expect(subject.total_points(comp("A"), tech_type)).to eq(2)
    end

    it "calculates the scores for B" do
      expect(subject.total_points(comp("B"))).to eq(7)
      expect(subject.total_points(comp("B"), pres_type)).to eq(2)
      expect(subject.total_points(comp("B"), tech_type)).to eq(1)
    end

    it "calculates the scores for C" do
      expect(subject.total_points(comp("C"))).to eq(10)
      expect(subject.total_points(comp("C"), pres_type)).to eq(3)
      expect(subject.total_points(comp("C"), tech_type)).to eq(2)
    end

    it "calculates places" do
      expect(subject.place(comp("A"))).to eq(2)
      expect(subject.place(comp("B"))).to eq(1)
      expect(subject.place(comp("C"))).to eq(3)
    end
  end
end
