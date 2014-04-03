require 'spec_helper'

describe ArtisticScoreCalculator do
  let(:competition) { FactoryGirl.build_stubbed(:competition) }
  subject { ArtisticScoreCalculator.new(competition) }
  describe "when calculating the placement from multiple scores" do
    it { subject.new_calc_place(10, [10,5,0]).should == 1 }
    it { subject.new_calc_place(5 , [10,5,0]).should == 2 }
    it { subject.new_calc_place(0 , [10,5,0]).should == 3 }
    describe "when there are ties" do
      it { subject.new_calc_place(5 , [10,5,5,0]).should == 2 }
      it { subject.new_calc_place(0 , [10,5,5,0]).should == 4 }
    end
  end

  describe "when calculating the number of ties" do
    it { subject.new_ties(1, [1]).should == 1 }
    it { subject.new_ties(1, [1, 1]).should == 2 }
    it { subject.new_ties(1, [1, 2]).should == 1 }
    it { subject.new_ties(1, [2, 1, 2]).should == 1 }
  end

  describe "when calculating the placing points" do
    it { subject.new_calc_placing_points(1, 1).should == 1 }
    it { subject.new_calc_placing_points(1, 2).should == 1.5 }
    it { subject.new_calc_placing_points(2, 1).should == 2 }
    it { subject.new_calc_placing_points(2, 2).should == 2.5 }
    it { subject.new_calc_placing_points(2, 3).should == 3 }
  end

  describe "when determining place from points" do
    let(:first) { 1 }
    let(:second) { 2 }
    let(:all_scores) { [first, second, 3, 4] }
    let(:tie_score) { 1 }
    let(:all_tie_scores) { [1, 2, 3, 4] }

    it { subject.new_place(first, all_scores, tie_score, all_tie_scores).should == 1 }
    it { subject.new_place(second, all_scores, 2, all_tie_scores).should == 2 }

    # if the overall scores are tied, fall back to the secondary scores for tie-breaker
    it { subject.new_place(1.5, [1.5, 1.5], 1, [1, 2]).should == 1 }
    it { subject.new_place(1.5, [1.5, 1.5], 2, [1, 2]).should == 2 }
  end
  describe "when calculating highest score" do
    #it { subject. }
  end
  describe "when calculating lowest score" do
    
  end
end

describe ArtisticScoreCalculator do
  before(:each) do
    @competition = FactoryGirl.create(:competition)
    @judge1 = FactoryGirl.create(:judge, :competition => @competition)
    @jt = @judge1.judge_type
    @calc = ArtisticScoreCalculator.new(@competition)
    @comp1 = FactoryGirl.create(:event_competitor, :competition => @competition)
    @comp2 = FactoryGirl.create(:event_competitor, :competition => @competition)
    @comp3 = FactoryGirl.create(:event_competitor, :competition => @competition)
  end
  describe "when calculating the placement points of an event" do
    before(:each) do
      @score1 = FactoryGirl.create(:score, :judge => @judge1, :competitor => @comp1, :val_1 => 10)
      @score2 = FactoryGirl.create(:score, :judge => @judge1, :competitor => @comp2, :val_1 => 5)
      @score3 = FactoryGirl.create(:score, :judge => @judge1, :competitor => @comp3, :val_1 => 0)
    end
    it "should be able to calculate on an invalid score" do
        @calc.calc_place(@comp1.scores.new).should == 0
    end

    it "should set the calc_placing_points according to scores" do
      @calc.calc_placing_points(@score1).should == 1
      @calc.calc_placing_points(@score2).should == 2
      @calc.calc_placing_points(@score3).should == 3
    end
    it "should have total_points of 0 (with 1 judge)" do
      @calc.total_points(@score1.competitor).should == 0.0
      @calc.total_points(@score2.competitor).should == 0.0
      @calc.total_points(@score3.competitor).should == 0.0
    end
    it "should calculate the place as empty" do
      @calc.calc_place(@score1).should == 1
      @calc.calc_place(@score2).should == 2
      @calc.calc_place(@score3).should == 3
    end

    describe "when calculating ties" do
      before(:each) do
        @score4 = FactoryGirl.create(:score, :judge => @judge1, :val_1 => 5)
      end
      it "gives both 2nd places 2.5 points" do
        @calc.ties(@score2).should == 2
        @calc.calc_placing_points(@score2).should == 2.5
        @calc.calc_placing_points(@score4).should == 2.5
      end
      it "should calculate the places" do
        @calc.calc_place(@score1).should == 1
        @calc.calc_place(@score2).should == 2
        @calc.calc_place(@score4).should == 2
        @calc.calc_place(@score3).should == 4
      end
      it "gives the 4th place 4 points" do
        @calc.calc_placing_points(@score3).should == 4
      end
    end
    describe "and there are 2 judges" do
      before(:each) do 
        @judge2 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
        @score2_1 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score1.competitor, :val_1 => 9)
        @score2_2 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score2.competitor, :val_1 => 0)
        @score2_3 = FactoryGirl.create(:score, :judge => @judge2, :competitor => @score3.competitor, :val_1 => 3)
      end
      it "calculates the 2nd judges points correctly" do
        @calc.calc_placing_points(@score2_1).should == 1
        @calc.calc_placing_points(@score2_2).should == 3
        @calc.calc_placing_points(@score2_3).should == 2
      end

      it "determines the highest place ranked" do
        @calc.lowest_score(@score1.competitor).should == 1
        @calc.lowest_score(@score2.competitor).should == 2 # by judge1
        @calc.lowest_score(@score3.competitor).should == 2 # by judge2

        @calc.lowest_score(@score2_1.competitor).should == 1
        @calc.lowest_score(@score2_2.competitor).should == 2 # by judge1
        @calc.lowest_score(@score2_3.competitor).should == 2 # by judge2
      end
      it "determines the lowest place ranked" do
        @calc.highest_score(@score1.competitor).should == 1
        @calc.highest_score(@score2.competitor).should == 3 # by judge2
        @calc.highest_score(@score3.competitor).should == 3 # by judge1

        @calc.highest_score(@score2_1.competitor).should == 1
        @calc.highest_score(@score2_2.competitor).should == 3 # by judge2
        @calc.highest_score(@score2_3.competitor).should == 3 # by judge1
      end

      it "has 0.0 for the total placing points, after subtracting high and low (only 2 judges)" do
        @calc.total_points(@score1.competitor).should == 0.0
        @calc.total_points(@score2.competitor).should == 0.0
        @calc.total_points(@score3.competitor).should == 0.0
      end

      describe "with a 3rd judge's scores" do
        before(:each) do
          @judge3 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
          @score3_1 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score1.competitor, :val_1 => 9)
          @score3_2 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score2.competitor, :val_1 => 4)
          @score3_3 = FactoryGirl.create(:score, :judge => @judge3, :competitor => @score3.competitor, :val_1 => 4)
        end
        it "has non-zero placing points" do
            @calc.total_points(@score1.competitor).should == 1.0
            @calc.total_points(@score2.competitor).should == 2.5
            @calc.total_points(@score3.competitor).should == 2.5
        end
        it "has non-zero placing points for correct judge_type" do
            @calc.total_points(@score1.competitor, @judge3.judge_type).should == 1.0
            @calc.total_points(@score2.competitor, @judge3.judge_type).should == 2.5
            @calc.total_points(@score3.competitor, @judge3.judge_type).should == 2.5
        end
        it "converts the place points into place" do
            @calc.place(@score1.competitor).should == 1
            @calc.place(@score2.competitor).should == 2
            @calc.place(@score3.competitor).should == 2
        end
        describe "when there are more competitors than scores, it marks the extras as 0" do
          before(:each) do
            @comp4 = FactoryGirl.create(:event_competitor, :competition => @competition)
          end

          it "puts that competitor as first" do
            @calc.place(@comp1).should == 1
          end

          it "puts the other competitor as NA" do
            @calc.place(@comp4).should == 0
          end
        end

        describe "if I have scores for the other judge_type, but not for this judge_type" do
            before(:each) do
                @jt = FactoryGirl.create(:judge_type, :name => "Technical")
                @judge = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt)
            end
            it "should be able to get the place" do
                @calc.place(@comp1).should == 1
            end
        end


        describe "with 3 technical judges too" do
          before(:each) do
            @judge4 = FactoryGirl.create(:judge, :competition => @competition)
            @jt2 = @judge4.judge_type
            @score4_1 = FactoryGirl.create(:score, :judge => @judge4, :competitor => @score1.competitor, :val_1 => 1)
            @score4_2 = FactoryGirl.create(:score, :judge => @judge4, :competitor => @score2.competitor, :val_1 => 2)
            @score4_3 = FactoryGirl.create(:score, :judge => @judge4, :competitor => @score3.competitor, :val_1 => 3)

            @judge5 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt2)
            @score5_1 = FactoryGirl.create(:score, :judge => @judge5, :competitor => @score1.competitor, :val_1 => 1)
            @score5_2 = FactoryGirl.create(:score, :judge => @judge5, :competitor => @score2.competitor, :val_1 => 2)
            @score5_3 = FactoryGirl.create(:score, :judge => @judge5, :competitor => @score3.competitor, :val_1 => 3)

            @judge6 = FactoryGirl.create(:judge, :competition => @competition, :judge_type => @jt2)
            @score6_1 = FactoryGirl.create(:score, :judge => @judge6, :competitor => @score1.competitor, :val_1 => 1)
            @score6_2 = FactoryGirl.create(:score, :judge => @judge6, :competitor => @score2.competitor, :val_1 => 2)
            @score6_3 = FactoryGirl.create(:score, :judge => @judge6, :competitor => @score3.competitor, :val_1 => 3)
          end

          it "has non-zero placing points for correct judge_type" do
            @calc.total_points(@score1.competitor, @judge4.judge_type).should == 3.0
            @calc.total_points(@score2.competitor, @judge4.judge_type).should == 2.0
            @calc.total_points(@score3.competitor, @judge4.judge_type).should == 1.0
          end

          it "has total_points for both judge_types, after eliminating high-low from each type" do
            @calc.total_points(@score1.competitor).should == 4.0
            @calc.total_points(@score2.competitor).should == 4.5
            @calc.total_points(@score3.competitor).should == 3.5
          end
          it "determines the places correctly" do
            @calc.place(@score1.competitor).should == 2
            @calc.place(@score2.competitor).should == 3
            @calc.place(@score3.competitor).should == 1
          end

          describe "when using NAUCC-style rules" do
            before(:each) do
                @calc = ArtisticScoreCalculator.new(@competition, false)
            end

              #10,5,0 -> 1,  2,  3 
              #9,0,3  -> 1,  3,  2
              #9,4,4  -> 1,2.5,2.5
  
              #1,2,3 -> 3,  2,  1
              #1,2,3 -> 3,  2,  1
              #1,2,3 -> 3,  2,  1
  
              #eliminate 1,3  2,3  3,1
            it "calculates the highest_score correctly by judge_type" do
              @calc.highest_score(@score1.competitor, @judge1.judge_type).should == 0.0
              @calc.highest_score(@score2.competitor, @judge1.judge_type).should == 3.0
              @calc.highest_score(@score3.competitor, @judge1.judge_type).should == 3.0

              @calc.highest_score(@score1.competitor, @judge4.judge_type).should == 3.0
              @calc.highest_score(@score2.competitor, @judge4.judge_type).should == 0.0
              @calc.highest_score(@score3.competitor, @judge4.judge_type).should == 0.0
            end

            it "calculates the lowest_score correctly by judge_type" do
              @calc.lowest_score(@score1.competitor, @judge1.judge_type).should == 1.0
              @calc.lowest_score(@score2.competitor, @judge1.judge_type).should == 2.0
              @calc.lowest_score(@score3.competitor, @judge1.judge_type).should == 0.0

              @calc.lowest_score(@score1.competitor, @judge4.judge_type).should == 0.0
              @calc.lowest_score(@score2.competitor, @judge4.judge_type).should == 0.0
              @calc.lowest_score(@score3.competitor, @judge4.judge_type).should == 1.0
            end

            it "has non-zero placing points for correct judge_type" do
              @calc.total_points(@score1.competitor, @judge1.judge_type).should == 2.0
              @calc.total_points(@score2.competitor, @judge1.judge_type).should == 2.5
              @calc.total_points(@score3.competitor, @judge1.judge_type).should == 4.5

              @calc.total_points(@score1.competitor, @judge4.judge_type).should == 6.0
              @calc.total_points(@score2.competitor, @judge4.judge_type).should == 6.0
              @calc.total_points(@score3.competitor, @judge4.judge_type).should == 2.0
            end
            it "has total_points for both judge_types, after eliminating high-low from each type" do
              @calc.total_points(@score1.competitor).should == 8.0
              @calc.total_points(@score2.competitor).should == 8.5
              @calc.total_points(@score3.competitor).should == 6.5
            end
            it "determines the places correctly" do
              @calc.place(@score1.competitor).should == 2
              @calc.place(@score2.competitor).should == 3
              @calc.place(@score3.competitor).should == 1
            end
          end
        end
      end
    end
  end

  describe "STREET Score when calculating the placement points of an event" do
    before(:each) do
      @competition = FactoryGirl.create(:street_competition)
      comp1 = FactoryGirl.create(:event_competitor, :competition => @competition)
      comp2 = FactoryGirl.create(:event_competitor, :competition => @competition)
      comp3 = FactoryGirl.create(:event_competitor, :competition => @competition)
      @judge1 = FactoryGirl.create(:judge, :competition => @competition)
      @jt = @judge1.judge_type
      @score1 = FactoryGirl.create(:street_score, :judge => @judge1, :competitor => comp1, :val_1 => 10)
      @score2 = FactoryGirl.create(:street_score, :judge => @judge1, :competitor => comp2, :val_1 => 5)
      @score3 = FactoryGirl.create(:street_score, :judge => @judge1, :competitor => comp3, :val_1 => 0)
      @calc = ArtisticScoreCalculator.new(@competition)
      @comp1 = comp1
    end
    it "should be able to calculate on an invalid score" do
        @calc.calc_place(@comp1.street_scores.new).should == 0
    end

    it "should set the calc_placing_points according to scores" do
      @calc.calc_placing_points(@score1).should == 1
    end
    it "should determine no ties" do
      @calc.ties(@score1).should == 1
    end
  end
end
