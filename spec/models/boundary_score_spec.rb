# == Schema Information
#
# Table name: boundary_scores
#
#  id               :integer          not null, primary key
#  competitor_id    :integer
#  judge_id         :integer
#  number_of_people :integer
#  major_dismount   :integer
#  minor_dismount   :integer
#  major_boundary   :integer
#  minor_boundary   :integer
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_boundary_scores_competitor_id                  (competitor_id)
#  index_boundary_scores_judge_id                       (judge_id)
#  index_boundary_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id) UNIQUE
#

require 'spec_helper'

describe BoundaryScore do
  it "requires that the fields be filled out" do
    bs = described_class.new
    expect(bs.valid?).to eq(false)
    bs.judge = FactoryBot.build_stubbed(:judge)
    bs.competitor = FactoryBot.build_stubbed(:event_competitor)

    bs.number_of_people = 4
    bs.major_dismount = 1
    bs.minor_dismount = 1
    bs.major_boundary = 1
    bs.minor_boundary = 1
    expect(bs.valid?).to eq(true)
  end

  describe "for a group of 1 people" do
    before do
      @bs = FactoryBot.build_stubbed(:boundary_score)
      @bs.number_of_people = 1
    end

    it "scores 10 for perfect score" do
      expect(@bs.total).to eq(10)
    end

    it "scores 1 less for a major dismount" do
      @bs.major_dismount = 1
      expect(@bs.total).to eq(9)
    end

    it "scores .5 less for a minor dismount" do
      @bs.minor_dismount = 1
      expect(@bs.total).to eq(9.5)
    end

    it "scores .5 less for a major boundary" do
      @bs.major_boundary = 1
      expect(@bs.total).to eq(9.5)
    end

    it "scores .25 less for a minor boundary" do
      @bs.minor_boundary = 1
      expect(@bs.total).to eq(9.75)
    end

    it "scores a compound score for multiple different violations" do
      @bs.major_dismount = 3
      @bs.major_boundary = 2
      @bs.minor_dismount = 3
      @bs.minor_boundary = 2
      expect(@bs.total).to eq(4)
    end
  end

  describe "for a group of 2 people" do
    before do
      @bs = FactoryBot.build_stubbed(:boundary_score)
      @bs.number_of_people = 2
    end

    it "scores 10 for perfect score" do
      expect(@bs.total).to eq(10)
    end

    it "scores 1 less for a major dismount" do
      @bs.major_dismount = 1
      expect(@bs.total).to eq(9)
    end

    it "scores .5 less for a minor dismount" do
      @bs.minor_dismount = 1
      expect(@bs.total).to eq(9.5)
    end

    it "scores .5 less for a major boundary" do
      @bs.major_boundary = 1
      expect(@bs.total).to eq(9.5)
    end

    it "scores .25 less for a minor boundary" do
      @bs.minor_boundary = 1
      expect(@bs.total).to eq(9.75)
    end

    it "scores a compound score for multiple different violations" do
      @bs.major_dismount = 3
      @bs.major_boundary = 2
      @bs.minor_dismount = 3
      @bs.minor_boundary = 2
      expect(@bs.total).to eq(4)
    end
  end

  describe "for a group of 3 people" do
    before do
      @bs = FactoryBot.build_stubbed(:boundary_score)
      @bs.number_of_people = 3
    end

    it "scores 10 for perfect score" do
      expect(@bs.total).to eq(10)
    end

    it "scores 0.66 less for a major dismount" do
      @bs.major_dismount = 1
      expect(@bs.total).to eq(9.333333333333334)
    end

    it "scores .33 less for a minor dismount" do
      @bs.minor_dismount = 1
      expect(@bs.total).to eq(9.666666666666666)
    end

    it "scores .33 less for a major boundary" do
      @bs.major_boundary = 1
      expect(@bs.total).to eq(9.666666666666666)
    end

    it "scores .166 less for a minor boundary" do
      @bs.minor_boundary = 1
      expect(@bs.total).to eq(9.833333333333334)
    end

    it "scores a compound score for multiple different violations" do
      @bs.major_dismount = 3
      @bs.major_boundary = 2
      @bs.minor_dismount = 3
      @bs.minor_boundary = 2
      expect(@bs.total).to eq(6)
    end
  end

  describe "for a group of 4" do
    before do
      @bs = FactoryBot.build_stubbed(:boundary_score)
      @bs.number_of_people = 4
    end

    it "scores 10 for perfect score" do
      expect(@bs.total).to eq(10)
    end

    it "scores .5 less for a major dismount" do
      @bs.major_dismount = 1
      expect(@bs.total).to eq(9.5)
    end

    it "scores .25 less for a major boundary" do
      @bs.major_boundary = 1
      expect(@bs.total).to eq(9.75)
    end

    it "scores .25 less for a minor dismount" do
      @bs.minor_dismount = 1
      expect(@bs.total).to eq(9.75)
    end

    it "scores .125 less for a minor boundary" do
      @bs.minor_boundary = 1
      expect(@bs.total).to eq(9.875)
    end

    it "scores a compound score for multiple different violations" do
      @bs.major_dismount = 3
      @bs.major_boundary = 2
      @bs.minor_dismount = 3
      @bs.minor_boundary = 2
      expect(@bs.total).to eq(7)
    end
  end

  describe "for a group of 8 people" do
    before do
      @bs = FactoryBot.build_stubbed(:boundary_score)
      @bs.number_of_people = 8
    end

    it "scores 10 for perfect score" do
      expect(@bs.total).to eq(10)
    end

    it "scores .25 less for a major dismount" do
      @bs.major_dismount = 1
      expect(@bs.total).to eq(9.75)
    end

    it "scores .125 less for a major boundary" do
      @bs.major_boundary = 1
      expect(@bs.total).to eq(9.875)
    end

    it "scores .125 less for a minor dismount" do
      @bs.minor_dismount = 1
      expect(@bs.total).to eq(9.875)
    end

    it "scores .0625 less for a minor boundary" do
      @bs.minor_boundary = 1
      expect(@bs.total).to eq(9.9375)
    end

    it "scores a compound score for multiple different violations" do
      @bs.major_dismount = 3
      @bs.major_boundary = 2
      @bs.minor_dismount = 3
      @bs.minor_boundary = 2
      expect(@bs.total).to eq(8.5)
    end
  end

  describe "for a group of 20 people" do
    before do
      @bs = FactoryBot.build_stubbed(:boundary_score)
      @bs.number_of_people = 20
    end

    it "scores 10 for perfect score" do
      expect(@bs.total).to eq(10)
    end

    it "scores .1 less for a major dismount" do
      @bs.major_dismount = 1
      expect(@bs.total).to eq(9.9)
    end

    it "scores .05 less for a major boundary" do
      @bs.major_boundary = 1
      expect(@bs.total).to eq(9.95)
    end

    it "scores .05 less for a minor dismount" do
      @bs.minor_dismount = 1
      expect(@bs.total).to eq(9.95)
    end

    it "scores .025 less for a minor boundary" do
      @bs.minor_boundary = 1
      expect(@bs.total).to eq(9.975)
    end

    it "scores a compound score for multiple different violations" do
      @bs.major_dismount = 3
      @bs.major_boundary = 2
      @bs.minor_dismount = 3
      @bs.minor_boundary = 2
      expect(@bs.total).to eq(9.4)
    end

    it "does not have a total below zero" do
      @bs.major_dismount = 500
      expect(@bs.total).to eq(0)
    end
  end
end
