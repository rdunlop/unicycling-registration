# == Schema Information
#
# Table name: competitors
#
#  id                       :integer          not null, primary key
#  competition_id           :integer
#  position                 :integer
#  custom_name              :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  status                   :integer          default(0)
#  lowest_member_bib_number :integer
#  geared                   :boolean          default(FALSE)
#  riding_wheel_size        :integer
#  notes                    :string(255)
#  heat                     :integer
#  riding_crank_size        :integer
#
# Indexes
#
#  index_competitors_event_category_id  (competition_id)
#

require 'spec_helper'

describe Competitor do
  before :each do
    @competition = FactoryGirl.build_stubbed(:timed_competition)
    @comp = FactoryGirl.build_stubbed(:event_competitor, competition: @competition)
    allow(@comp).to receive(:lower_is_better).and_return(true)
    Rails.cache.clear
  end

  it "has a time_result in thousands when no results" do
    expect(@comp.best_time_in_thousands).to eq(0)
  end

  describe "when there are time results" do
    before :each do
      @tr1 = FactoryGirl.build_stubbed(:time_result, :minutes => 1)
      allow(@comp).to receive(:finish_time_results).and_return([@tr1])
    end

    it "has a best_time_in_thousands" do
      expect(@comp.best_time_in_thousands).to eq(60000)
    end

    describe "when there is also a start time" do
      before :each do
        @tr2 = FactoryGirl.build_stubbed(:time_result, :is_start_time => true, :seconds => 10)
        allow(@comp).to receive(:start_time_results).and_return([@tr2])
      end

      it "has the correct best_time_in_thousands" do
        expect(@comp.best_time_in_thousands).to eq(50000)
      end
    end

    describe "when there is a matching heat + heat_time" do
      before :each do
        allow(@competition).to receive(:heat_time_for).with(1).and_return(30)
      end

      it "uses the heat time for start times" do
        @comp.heat = 1
        expect(@comp.best_time_in_thousands).to eq(30000)
      end
    end
  end
  describe "when there are multiple start and end times" do
    before :each do
      @start1 = FactoryGirl.build_stubbed(:time_result, :is_start_time => true, :minutes => 1)
      @start2 = FactoryGirl.build_stubbed(:time_result, :is_start_time => true, :minutes => 10)

      @end1 = FactoryGirl.build_stubbed(:time_result, :minutes => 2, :seconds => 30)
      @end2 = FactoryGirl.build_stubbed(:time_result, :minutes => 10, :seconds => 45)

      allow(@comp).to receive(:start_time_results).and_return([@start1, @start2])
      allow(@comp).to receive(:finish_time_results).and_return([@end1, @end2])
    end

    describe "with lower_is_better" do
      before :each do
        Rails.cache.clear
        allow(@comp).to receive(:lower_is_better).and_return(true)
      end
      it "has the correct best_time_in_thousands" do
        expect(@comp.best_time_in_thousands).to eq(45000)
      end
    end

    describe "with higher_is_better" do
      before :each do
        Rails.cache.clear
        allow(@comp).to receive(:lower_is_better).and_return(false)
      end
      it "has the correct best_time_in_thousands" do
        expect(@comp.best_time_in_thousands).to eq(90000)
      end
    end
  end

  describe "when there are end times without start times" do
    before :each do
      @end1 = FactoryGirl.build_stubbed(:time_result, :minutes => 2, :seconds => 30)
      @end2 = FactoryGirl.build_stubbed(:time_result, :minutes => 10, :seconds => 45)

      allow(@comp).to receive(:finish_time_results).and_return([@end1, @end2])
    end

    it "has the correct best_time_in_thousands" do
      expect(@comp.best_time_in_thousands).to eq(150000)
    end
  end
end

describe Competitor do
  before(:each) do
    @comp = FactoryGirl.create(:event_competitor)
  end

  it "should join a registrant and a event" do
    reg = FactoryGirl.create(:registrant)

    competition = FactoryGirl.create(:competition)

    comp = Competitor.new
    comp.registrants << reg
    comp.competition = competition
    comp.position = 1
    comp.save.should == true
  end
  it "should modify the other competitor's position" do
    competition = FactoryGirl.create(:competition)
    reg1 = FactoryGirl.create(:registrant)
    reg2 = FactoryGirl.create(:registrant)

    comp = Competitor.new
    comp.registrants << reg1
    comp.competition = competition
    comp.position = 1
    comp.save.should == true

    comp = Competitor.new
    comp.registrants << reg2
    comp.competition = competition
    comp.position = 1
    comp.save.should == true

    comps = competition.competitors
    comps.count.should == 2
    comps[0].position.should == 1
    comps[1].position.should == 2
  end
  it "should have name/id from the registrant" do
    reg  = @comp.registrants.first

    @comp.name.should == reg.name
    @comp.bib_number.should == reg.external_id.to_s
  end
  it "should be elgiible" do
    @comp.ineligible.should == false
  end
  it "should not set the external name if it is a blank-string" do
    @comp.custom_name = ""
    reg = @comp.registrants.first

    @comp.bib_number.should == reg.external_id.to_s
    @comp.name.should == reg.name
  end
  it "should allow setting the custom_name to nil" do
    @comp.custom_name = nil
    @comp.valid?.should == true
  end
  it "must have 3 competitors to allow a custom name" do
    @comp.custom_name = "Sargent Pepper"
    @comp.valid?.should == false
    member2 = @comp.members.build
    member3 = @comp.members.build
    member2.registrant = FactoryGirl.create(:registrant)
    member3.registrant = FactoryGirl.create(:registrant)
    @comp.valid?.should == true
    @comp.valid?.should == true
    @comp.name.should == "Sargent Pepper"
  end
  it "setting the same position for another competitor should modify the original competitor" do
    c2 = FactoryGirl.build(:event_competitor, :competition => @comp.competition, :position => @comp.position)

    c2.valid?.should == true
    c2.save.should == true

    comp_again = Competitor.find(@comp.id)
    comp_again.position.should_not == c2.position
  end
  describe "when checking the export_id field" do
    it "should return the registrant when only one" do
      @comp.export_id.should == @comp.registrants.first.external_id
    end
    it "should return the first registrant when two registrants" do
      @comp.registrants << FactoryGirl.create(:registrant)
      @comp.save!
      @comp.export_id.should == @comp.registrants.first.external_id
    end
  end

  it "should have a name, even without any registrants" do
    member = @comp.members(true).first

    member.destroy
    @comp.reload
    @comp.name.should == "(No registrants)"
    @comp.bib_number.should == "(No registrants)"
  end

  describe "when it has multiple members" do
    before(:each) do
      FactoryGirl.create(:event_configuration, :start_date => Date.new(2010, 01, 01))
      member = @comp.members(true).first
      @reg1 = member.registrant

      Delorean.jump 2
      @comp.reload
      member2 = FactoryGirl.create(:member, :competitor => @comp)
      @comp.reload
      @reg2 = member2.registrant
    end
    it "should display the external id's for all members" do
      @comp.bib_number.should == (@reg1.external_id.to_s + "," + @reg2.external_id.to_s)
    end
    it "should display the ages for all members (when they are the same)" do
      @comp.age.should == (@reg1.age)
    end

    it "should store the mimimum bib_number" do
      lowest = [@reg1.bib_number, @reg2.bib_number].min
      expect(@comp.lowest_member_bib_number).to be(lowest)
    end

    it "should display the maximum ages for all members (when they are different)" do
      Delorean.jump 2
      @reg3 = FactoryGirl.create(:registrant, :birthday => Date.new(1980, 02, 10))
      @comp2 = FactoryGirl.create(:event_competitor)
      member3 = FactoryGirl.create(:member, :competitor => @comp2, :registrant => @reg3)
      @comp2.reload

      @comp2.age.should == @reg3.age
    end
    it "should display '(mixed)', if there are multiple members (even if they are the same gender)" do
      # this is so that the overall placing calculation works properly with mixed-gender groups
      @comp.gender.should == "(mixed)"
    end

    it "can determine the majority country" do
      expect(@comp.majority_country(["USA"])).to eq("USA")
      expect(@comp.majority_country(["USA", nil])).to eq("USA")
      expect(@comp.majority_country(["USA", "Canada"])).to eq("Canada, USA")
      expect(@comp.majority_country(["USA", "Canada", "Canada"])).to eq("Canada")
      expect(@comp.majority_country([nil, nil])).to eq(nil)
    end
    it "should display the source country" do
      @comp.country.should == @reg1.country
    end

    it "should display (mixed) if both genders exist" do
      Delorean.jump 2
      @reg3 = FactoryGirl.create(:registrant, :gender => "Female")
      member3 = FactoryGirl.create(:member, :competitor => @comp, :registrant => @reg3)
      @comp.reload

      @comp.gender.should == "(mixed)"
    end

    it "should respond to member_has_bib_number?" do
      @comp.member_has_bib_number?(@reg1.bib_number).should == true
      @comp.member_has_bib_number?(@reg2.bib_number).should == true
      @comp.member_has_bib_number?(-1).should == false
    end
  end

  describe "when a join pair exists" do
    before(:each) do
      @reg = FactoryGirl.create(:registrant)

      @competition = FactoryGirl.create(:competition)

      @competition.create_competitors_from_registrants([@reg])
      @cr = @competition.competitors.first

      @score = Score.new
      @score.val_1 = 1.0
      @score.val_2 = 2.0
      @score.val_3 = 3.0
      @score.val_4 = 4.0
      @score.judge = FactoryGirl.create(:judge,
                                        :user => FactoryGirl.create(:admin_user),
                                        :judge_type => FactoryGirl.create(:judge_type))
      @score.competitor = @cr
      @score.save
      @competition.reload
      @reg.reload
    end

    it "should be able to access the reg via event" do
      @competition.registrants.should == [@reg]
    end
    it "should be able to access the event via reg" do
      @reg.competitions.should == [@competition]
    end
    it "should be able to access the competitors via competition" do
      @competition.competitors.should == [@cr]
    end
    it "should be able to access the competitors via registrant" do
      @reg.competitors.should == [@cr]
    end
    it "should be able to access the scores via competitor" do
      @cr.scores.should == [@score]
    end
  end
  describe "with a standard execution score" do
    before(:each) do
      @st_score = FactoryGirl.create(:standard_execution_score)
    end

    it "should be able to get the scores from the competitor" do
      @st_score.competitor.standard_execution_scores.should == [@st_score]
    end
  end
  describe "with a score" do
    before(:each) do
      @score = FactoryGirl.create(:score)
    end
    it "should delete the score when the associated competitor is deleted" do
      @comp = @score.competitor
      Score.count.should == 1
      @comp.destroy
      Score.count.should == 0
    end
  end
  describe "with a boundary_score" do
    before(:each) do
      @score = FactoryGirl.create(:boundary_score)
    end
    it "should delete the boundary_score when the associated competitor is deleted" do
      @comp = @score.competitor
      BoundaryScore.count.should == 1
      @comp.destroy
      BoundaryScore.count.should == 0
    end
  end
  describe "with a distance attempt" do
    before(:each) do
      Delorean.jump 2
      @da = DistanceAttempt.new
    end
    it "should be accessible from the competitor" do
      da = FactoryGirl.create(:distance_attempt, :competitor => @comp)

      @comp.distance_attempts.should == [da]
    end

    it "should delete related distance_attempts if the competitor is deleted" do
      da = FactoryGirl.create(:distance_attempt)

      comp = da.competitor
      DistanceAttempt.count.should == 1
      Delorean.jump 2

      comp.destroy
      DistanceAttempt.count.should == 0
    end

    it "should indicate double_fault if two attempts at the same distance are found" do
      @comp.double_fault?.should == false
      da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)
      @comp.reload.double_fault?.should == false
      Delorean.jump 2
      da2 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)

      @comp.reload.double_fault?.should == true
    end
    it "should NOT indicate double_fault if two consecutive attempts at different distances are found" do
      @comp.double_fault?.should == false
      da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)
      @comp.reload.double_fault?.should == false
      Delorean.jump 2
      da2 = FactoryGirl.create(:distance_attempt, :distance => da1.distance + 1, :competitor => @comp, :fault => true)

      @comp.reload.double_fault?.should == false
    end

    it "should return the max attempted distance" do
      @comp.max_attempted_distance.should == 0
      @comp.max_successful_distance.should == 0
      da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)
      @comp.reload.max_attempted_distance.should == da1.distance
      @comp.reload.max_successful_distance.should == 0
    end

    it "should return the attempts is descending distance order" do
      da1 = FactoryGirl.create(:distance_attempt, :distance => 1, :competitor => @comp, :fault => false)
      da2 = FactoryGirl.create(:distance_attempt, :distance => 2, :competitor => @comp, :fault => false)
      da3 = FactoryGirl.create(:distance_attempt, :distance => 3, :competitor => @comp, :fault => false)

      @comp.distance_attempts.should == [da3, da2, da1]
    end
    it "should return the attempts in descending attempt order (if the same distance)" do
      da1 = FactoryGirl.create(:distance_attempt, :distance => 1, :competitor => @comp, :fault => true)
      da2 = FactoryGirl.create(:distance_attempt, :distance => 1, :competitor => @comp, :fault => false)

      @comp.distance_attempts.should == [da2, da1]
    end

    it "should describe the status clearly" do
      @comp.distance_attempt_status.should == "Not Attempted"
    end

    describe "when attempts have already been made" do
      before (:each) do
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 10, :fault => false)
        Delorean.jump 2
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 15, :fault => true)
        Delorean.jump 2
      end

      it "should not be allowed to attempt a smaller distance" do
        da = FactoryGirl.build(:distance_attempt, :competitor => @comp, :distance => 5)

        da.valid?.should == false
      end
      it "should return the max successful distance" do
        @comp.max_successful_distance.should == 10
      end

      it "should not allow another attempt when in double-fault" do
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 15, :fault => true)
        da = FactoryGirl.build(:distance_attempt, :competitor => @comp, :distance => 25, :fault => false)

        @comp.reload.double_fault?.should == true
        da.valid?.should == false
      end

      describe "when there are 2 faults" do
        before(:each) do
          @da2 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 15, :fault => true)
        end
        it "should allow the 2nd attempt to also be a fault" do

          Competitor.find(@comp).double_fault?.should == true
          @da2.valid?.should == true
        end
        it "should describe the status" do
          @comp.reload.distance_attempt_status.should == "Finished. Final Score 10"
        end
      end

      it "should allow multiple faults, interspersed within the attempts" do
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 20, :fault => false)
        Delorean.jump 2
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 25, :fault => true)

        da = FactoryGirl.build(:distance_attempt, :competitor => @comp, :distance => 25, :fault => false)

        da.valid?.should == true
      end

      it "should describe its status clearly" do
        @comp.reload.distance_attempt_status.should == "Fault. Next Distance 15+"
      end

      describe "the last attempt was a success" do
        before(:each) do
          FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 20, :fault => false)
        end
        it "should have a nice status" do
          @comp.reload.distance_attempt_status.should == "Success. Next Distance 21+"
        end
      end

      describe "with a tie_breaker result" do
        before :each do
          FactoryGirl.create(:tie_break_adjustment, competitor: @comp, tie_break_place: 1)
        end

        it "should have a non-0 tie breaker adjustment value" do
          expect(@comp.tie_breaker_adjustment_value).to eq(0.9)
        end
      end
      it "should have a 0 tie_breaker_adjustment" do
        expect(@comp.tie_breaker_adjustment_value).to eq(0)
      end
    end
  end

  describe "when it has multiple time results" do
    describe "when there are DQs and live results" do
      before :each do
        @comp.competition.scoring_class = "Shortest Time"
        @end1 = FactoryGirl.create(:time_result, competitor: @comp, :minutes => 2, :seconds => 30)
        @end2 = FactoryGirl.create(:time_result, competitor: @comp, :minutes => 0, :seconds => 45, status: "DQ")
      end

      it "doesn't choose DQ as the best time" do
        expect(@comp.best_time_in_thousands).to eq(150000)
      end
    end
  end

  describe "with an ineligible registrant" do
    before(:each) do
      @reg = @comp.registrants(true).first
      @reg.ineligible = true
      @reg.save!
    end

    it "should be ineligible itself" do
      @comp.ineligible.should == true
    end
  end
end
