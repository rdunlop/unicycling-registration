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
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe BoundaryScore do
  it "should require that the fields be filled out" do
    bs = BoundaryScore.new
    bs.valid?.should == false
    bs.judge = FactoryGirl.build_stubbed(:judge)
    bs.competitor = FactoryGirl.build_stubbed(:event_competitor)

    bs.number_of_people = 4
    bs.major_dismount = 1
    bs.minor_dismount = 1
    bs.major_boundary = 1
    bs.minor_boundary = 1
    bs.valid?.should == true
  end

  describe "for a group of 1 people" do
    before(:each) do
        @bs = FactoryGirl.build_stubbed(:boundary_score)
        @bs.number_of_people = 1
    end

    it "should score 10 for perfect score" do
        @bs.total.should == 10
    end
    it "should score 1 less for a major dismount" do
        @bs.major_dismount = 1
        @bs.total.should == 9
    end
    it "should score .5 less for a minor dismount" do
        @bs.minor_dismount = 1
        @bs.total.should == 9.5
    end
    it "should score .5 less for a major boundary" do
        @bs.major_boundary = 1
        @bs.total.should == 9.5
    end
    it "should score .25 less for a minor boundary" do
        @bs.minor_boundary = 1
        @bs.total.should == 9.75
    end
    it "should score a compound score for multiple different violations" do
        @bs.major_dismount = 3
        @bs.major_boundary = 2
        @bs.minor_dismount = 3
        @bs.minor_boundary = 2
        @bs.total.should == 4
    end
  end
  describe "for a group of 2 people" do
    before(:each) do
        @bs = FactoryGirl.build_stubbed(:boundary_score)
        @bs.number_of_people = 2
    end

    it "should score 10 for perfect score" do
        @bs.total.should == 10
    end
    it "should score 1 less for a major dismount" do
        @bs.major_dismount = 1
        @bs.total.should == 9
    end
    it "should score .5 less for a minor dismount" do
        @bs.minor_dismount = 1
        @bs.total.should == 9.5
    end
    it "should score .5 less for a major boundary" do
        @bs.major_boundary = 1
        @bs.total.should == 9.5
    end
    it "should score .25 less for a minor boundary" do
        @bs.minor_boundary = 1
        @bs.total.should == 9.75
    end
    it "should score a compound score for multiple different violations" do
        @bs.major_dismount = 3
        @bs.major_boundary = 2
        @bs.minor_dismount = 3
        @bs.minor_boundary = 2
        @bs.total.should == 4
    end
  end
  describe "for a group of 3 people" do
    before(:each) do
        @bs = FactoryGirl.build_stubbed(:boundary_score)
        @bs.number_of_people = 3
    end

    it "should score 10 for perfect score" do
        @bs.total.should == 10
    end
    it "should score 0.66 less for a major dismount" do
        @bs.major_dismount = 1
        @bs.total.should == 9.333333333333334
    end
    it "should score .33 less for a minor dismount" do
        @bs.minor_dismount = 1
        @bs.total.should == 9.666666666666666
    end
    it "should score .33 less for a major boundary" do
        @bs.major_boundary = 1
        @bs.total.should == 9.666666666666666
    end
    it "should score .166 less for a minor boundary" do
        @bs.minor_boundary = 1
        @bs.total.should == 9.833333333333334
    end
    it "should score a compound score for multiple different violations" do
        @bs.major_dismount = 3
        @bs.major_boundary = 2
        @bs.minor_dismount = 3
        @bs.minor_boundary = 2
        @bs.total.should == 6
    end
  end
  describe "for a group of 4" do
    before(:each) do
        @bs = FactoryGirl.build_stubbed(:boundary_score)
        @bs.number_of_people = 4
    end

    it "should score 10 for perfect score" do
        @bs.total.should == 10
    end
    it "should score .5 less for a major dismount" do
        @bs.major_dismount = 1
        @bs.total.should == 9.5
    end
    it "should score .25 less for a major boundary" do
        @bs.major_boundary = 1
        @bs.total.should == 9.75
    end
    it "should score .25 less for a minor dismount" do
        @bs.minor_dismount = 1
        @bs.total.should == 9.75
    end
    it "should score .125 less for a minor boundary" do
        @bs.minor_boundary = 1
        @bs.total.should == 9.875
    end
    it "should score a compound score for multiple different violations" do
        @bs.major_dismount = 3
        @bs.major_boundary = 2
        @bs.minor_dismount = 3
        @bs.minor_boundary = 2
        @bs.total.should == 7
    end
  end

  describe "for a group of 8 people" do
    before(:each) do
        @bs = FactoryGirl.build_stubbed(:boundary_score)
        @bs.number_of_people = 8
    end

    it "should score 10 for perfect score" do
        @bs.total.should == 10
    end
    it "should score .25 less for a major dismount" do
        @bs.major_dismount = 1
        @bs.total.should == 9.75
    end
    it "should score .125 less for a major boundary" do
        @bs.major_boundary = 1
        @bs.total.should == 9.875
    end
    it "should score .125 less for a minor dismount" do
        @bs.minor_dismount = 1
        @bs.total.should == 9.875
    end
    it "should score .0625 less for a minor boundary" do
        @bs.minor_boundary = 1
        @bs.total.should == 9.9375
    end
    it "should score a compound score for multiple different violations" do
        @bs.major_dismount = 3
        @bs.major_boundary = 2
        @bs.minor_dismount = 3
        @bs.minor_boundary = 2
        @bs.total.should == 8.5
    end
  end
  describe "for a group of 20 people" do
    before(:each) do
        @bs = FactoryGirl.build_stubbed(:boundary_score)
        @bs.number_of_people = 20
    end

    it "should score 10 for perfect score" do
        @bs.total.should == 10
    end
    it "should score .1 less for a major dismount" do
        @bs.major_dismount = 1
        @bs.total.should == 9.9
    end
    it "should score .05 less for a major boundary" do
        @bs.major_boundary = 1
        @bs.total.should == 9.95
    end
    it "should score .05 less for a minor dismount" do
        @bs.minor_dismount = 1
        @bs.total.should == 9.95
    end
    it "should score .025 less for a minor boundary" do
        @bs.minor_boundary = 1
        @bs.total.should == 9.975
    end
    it "should score a compound score for multiple different violations" do
        @bs.major_dismount = 3
        @bs.major_boundary = 2
        @bs.minor_dismount = 3
        @bs.minor_boundary = 2
        @bs.total.should == 9.4
    end

    it "should not have a total below zero" do
        @bs.major_dismount = 500
        @bs.total.should == 0
    end
  end
end
