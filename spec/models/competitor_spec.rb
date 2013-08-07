require 'spec_helper'

describe Competitor do
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
      comp = FactoryGirl.create(:event_competitor)
      reg  = comp.registrants.first

      comp.name.should == reg.name
      comp.external_id.should == reg.external_id.to_s
    end
    it "should be elgiible" do
      comp = FactoryGirl.create(:event_competitor)
      comp.ineligible.should == false
    end
    it "should allow setting the custom_external_id to nil" do
      comp = FactoryGirl.build(:event_competitor)
      comp.custom_external_id = nil
      comp.save.should == true
    end
    it "should not set the external id or external name if they are blank-string" do
      comp = FactoryGirl.create(:event_competitor, :custom_external_id => "", :custom_name => "")
      reg = comp.registrants.first

      comp.external_id.should == reg.external_id.to_s
      comp.name.should == reg.name
    end
    it "should allow setting the custom_name to nil" do
      comp = FactoryGirl.build(:event_competitor)
      comp.custom_name = nil
      comp.save.should == true
    end
    it "when the custom_external_id is set, return it instead of registrants'" do
      comp = FactoryGirl.create(:event_competitor)
      comp.external_id.should == comp.registrants.first.external_id.to_s

      comp.custom_external_id = 12345
      comp.external_id.should == "12345"
    end
    it "when the custom_name is set, return it instead of registrants'" do
      comp = FactoryGirl.create(:event_competitor)
      comp.name.should == comp.registrants.first.name

      comp.custom_name = "Sargent Pepper"
      comp.name.should == "Sargent Pepper"
    end
    it "setting the same position for another competitor should modify the original competitor" do
        comp = FactoryGirl.create(:event_competitor)
        
        c2 = FactoryGirl.build(:event_competitor, :competition => comp.competition, :position => comp.position)

        c2.valid?.should == true
        c2.save.should == true


        comp_again = Competitor.find(comp.id)
        comp_again.position.should_not == c2.position
    end
    describe "when checking the export_id field" do
        before(:each) do
            @comp = FactoryGirl.create(:event_competitor)
        end
        it "should return the registrant when only one" do
            @comp.export_id.should == @comp.registrants.first.external_id
        end
        it "should return the first registrant when two registrants" do
            @comp.registrants << FactoryGirl.create(:registrant)
            @comp.save!
            @comp.export_id.should == @comp.registrants.first.external_id
        end

        it "should return the custom_external_id, when set" do
            @comp.custom_external_id = 12341
            @comp.export_id.should == 12341
        end
    end

    it "should have a name, even without any registrants" do
        comp = FactoryGirl.create(:event_competitor)
        member = comp.members(true).first

        member.destroy

        comp.name.should == "(No registrants)"
        comp.external_id.should == "(No registrants)"
    end

    describe "when it has multiple members" do
        before(:each) do
            FactoryGirl.create(:event_configuration, :start_date => Date.new(2010,01,01))
            @comp = FactoryGirl.create(:event_competitor)
            member = @comp.members(true).first
            @reg1 = member.registrant

            Delorean.jump 2
            member2 = FactoryGirl.create(:member, :competitor => @comp)
            @reg2 = member2.registrant
        end
        it "should display the external id's for all members" do
            @comp.external_id.should == (@reg1.external_id.to_s + "," + @reg2.external_id.to_s)
        end
        it "should display the ages for all members (when they are the same)" do
            @comp.age.should == (@reg1.age.to_s)
        end
        it "should display the ages for all members (when they are different)" do
            Delorean.jump 2
            @reg3 = FactoryGirl.create(:registrant, :birthday => Date.new(1980, 02, 10))
            member3 = FactoryGirl.create(:member, :competitor => @comp, :registrant => @reg3)
            @comp.reload

            @comp.age.should == (@reg1.age.to_s + "-" + @reg3.age.to_s)
        end
        it "should display '(mixed)', if there are multiple members (even if they are the same gender)" do
          # this is so that the overall placing calculation works properly with mixed-gender groups
            @comp.gender.should == "(mixed)"
        end

        it "should display (mixed) if both genders exist" do
            Delorean.jump 2
            @reg3 = FactoryGirl.create(:registrant, :gender => "Female")
            member3 = FactoryGirl.create(:member, :competitor => @comp, :registrant => @reg3)

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

            @cr = Competitor.new
            @cr.registrants << @reg
            @cr.competition = @competition
            @cr.position = 1
            @cr.save

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
  describe "with a street_score" do
    before(:each) do
      @comp = FactoryGirl.create(:event_competitor)
    end

    it "should be createable from the competitor" do
        @comp.street_scores.create.should be_a_new(StreetScore)
    end
    it "should be able to find associated street scores" do
        ss = FactoryGirl.create(:street_score, :competitor => @comp)

        @comp.street_scores.should == [ss]
    end
  end
  describe "with a distance attempt" do
    before(:each) do
      @comp = FactoryGirl.create(:event_competitor)
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

      comp.destroy
      DistanceAttempt.count.should == 0
    end

    it "should indicate double_fault if two attempts at the same distance are found" do
      @comp.double_fault?.should == false
      da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)
      @comp.double_fault?.should == false
      da2 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)

      @comp.double_fault?.should == true
    end
    it "should indicate double_fault if two consecutive attempts at different distances are found" do
      @comp.double_fault?.should == false
      da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)
      @comp.double_fault?.should == false
      da2 = FactoryGirl.create(:distance_attempt, :distance => da1.distance + 1, :competitor => @comp, :fault => true)

      @comp.double_fault?.should == true
    end

    it "should return the max attempted distance" do
      @comp.max_attempted_distance.should == 0
      @comp.max_successful_distance.should == 0
      da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp, :fault => true)
      @comp.max_attempted_distance.should == da1.distance
      @comp.max_successful_distance.should == 0
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
        @comp.status.should == "Not Attempted"
    end

    describe "when attempts have already been made" do
      before (:each) do
        @comp = FactoryGirl.create(:event_competitor)
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 10, :fault => false)
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 15, :fault => true)
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
  
          @comp.double_fault?.should == true
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
            @comp.status.should == "Finished. Final Score 10"
        end
      end
  
      it "should allow multiple faults, interspersed within the attempts" do
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 20, :fault => false)
        FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 25, :fault => true)
  
        da = FactoryGirl.build(:distance_attempt, :competitor => @comp, :distance => 25, :fault => false)
  
        da.valid?.should == true
      end

      it "should describe its status clearly" do
        @comp.status.should == "Fault. Next Distance 15+"
      end

      describe "the last attempt was a success" do
        before(:each) do
          FactoryGirl.create(:distance_attempt, :competitor => @comp, :distance => 20, :fault => false)
        end
        it "should have a nice status" do
            @comp.status.should == "Success. Next Distance 21+"
        end
      end
    end
  end

  describe "with an ineligible registrant" do
    before(:each) do
      @competitor = FactoryGirl.create(:event_competitor)
      @reg = @competitor.registrants(true).first
      @reg.ineligible = true
      @reg.save!
    end

    it "should be ineligible itself" do
      @competitor.ineligible.should == true
    end
  end
end
