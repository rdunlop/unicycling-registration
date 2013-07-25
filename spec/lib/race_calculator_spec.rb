require 'spec_helper'

describe RaceCalculator do
  describe "when calculating the placing of timed races" do
    before(:each) do
      @event_configuration = FactoryGirl.create(:event_configuration, :start_date => Date.today)
      @event = FactoryGirl.create(:event)
      @event_category = @event.event_categories.first
      @age_group_entry = FactoryGirl.create(:age_group_entry) # 0-100 age group
      @competition = FactoryGirl.create(:competition)
      @event_category.competition = @competition
      @event_category.age_group_type = @age_group_entry.age_group_type
      @event_category.save!
      FactoryGirl.create(:event_configuration, :start_date => Date.new(2013,01,01))
      # Note: Registrants are born in 1990, thus are 22 years old
      @tr1 = FactoryGirl.create(:time_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition))
      @tr2 = FactoryGirl.create(:time_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition))
      @tr3 = FactoryGirl.create(:time_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition))
      @tr4 = FactoryGirl.create(:time_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition))

      @calc = RaceCalculator.new(@competition)
    end
    describe "with 2 age_groups" do
      before(:each) do
        @age_group_type = @age_group_entry.age_group_type
        @age_group_entry2 = FactoryGirl.create(:age_group_entry, :age_group_type => @age_group_type, :start_age => 50, :end_age => 100, :short_description => "50-100")
        @age_group_entry.start_age = 0
        @age_group_entry.end_age = 49
        @age_group_entry.save!
      end

      it "doesn't place people in the 2nd age group when called by the first" do
        @tr1.thousands = 1
        @tr1.save!
        @tr2.thousands = 2
        @tr2.save!

        @reg = @tr1.competitor.registrants.first
        @reg.birthday= Date.today - 1.year
        @reg.responsible_adult_name = "Bob Smith"
        @reg.responsible_adult_phone = "911"
        @reg.save!
        @reg.age.should == 1

        @reg = @tr2.competitor.registrants.first
        @reg.birthday = Date.today - 60.years
        @reg.save!
        @reg.age.should == 60

        @calc.update_all_places

        @tr1.place.should == 1 # not a tie, different groups
        @tr2.place.should == 1 # not a tie, different groups
      end
    end

    it "places everyone as 0 if they have no time" do
      @calc.update_all_places

      @tr1.place.should == 0
      @tr2.place.should == 0
      @tr3.place.should == 0
      @tr4.place.should == 0
    end

    it "places the first place as first" do
      @tr1.thousands = 1
      @tr1.save!

      @calc.update_all_places

      @tr1.place.should == 1
    end

    it "places DQ's as 'DQ'" do
      @tr1.thousands = 1
      @tr1.disqualified = true
      @tr1.save!

      @calc.update_all_places

      @tr1.place.should == "DQ"
    end

    describe "when tr1 is slower than tr2" do
      before(:each) do
        @tr1.thousands = 0
        @tr1.seconds = 30
        @tr1.minutes = 3
        @tr1.save!

        # faster:
        @tr2.thousands = 120
        @tr2.seconds = 40
        @tr2.minutes = 2
        @tr2.save!
      end
      it "places fast times first" do

        @calc.update_all_places

        @tr1.place.should == 2
        @tr2.place.should == 1
      end
      describe "when the first competitor is ineligible" do
        before(:each) do
          @reg = @tr2.competitor.registrants.first
          @reg.ineligible = true
          @reg.save!
          @calc.update_all_places
        end

        it "places the faster competitor first" do
          @tr2.place.should == 1
        end
        it "places the slower competitor (eligible) as 1st also" do
          @tr1.place.should == 1
        end
      end
    end

    describe "if 2 times are identical" do
      before(:each) do
        @tr1.minutes = 1
        @tr1.save!
        @tr2.minutes = 1
        @tr2.save!
      end
      it "ties for first" do
        @calc.update_all_places

        @tr1.place.should == 1
        @tr2.place.should == 1
      end

      it "places slower score as 3rd place" do
        @tr3.minutes = 2
        @tr3.save!

        @calc.update_all_places

        @tr3.place.should == 3
      end

      describe "if 3-way tie" do
        before(:each) do
          @tr3.minutes = 1
          @tr3.save!

          @tr4.minutes = 2
          @tr4.save!
        end

        it "ties 3 for first, and one for 4th" do
          @calc.update_all_places

          @tr1.place.should == 1
          @tr2.place.should == 1
          @tr3.place.should == 1
          @tr4.place.should == 4
        end
      end
    end
  end
  describe "when calculating multiple scores (bug)" do
    it "has increasing thousands" do
      @all_together = FactoryGirl.create(:age_group_type)
      entr = FactoryGirl.create(:age_group_entry, :age_group_type => @all_together, :start_age => 0, :end_age => 100, :gender => "Male")
      @comp = FactoryGirl.create(:competition, :age_group_type => @all_together)
      tr1 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 15, :thousands => 935, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))
      tr2 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 23, :thousands => 97, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))
      tr4 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 26, :thousands => 745, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))
      tr5 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 28, :thousands => 498, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))
      tr3 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 25, :thousands => 206, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))
      tr6 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 32, :thousands => 508, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))
      tr7 = FactoryGirl.create(:time_result, :minutes => 1, :seconds => 32, :thousands => 815, :competitor => FactoryGirl.create(:event_competitor, :competition => @comp))

      rc = RaceCalculator.new(@comp)
      rc.update_all_places
      tr1.place.should == 1
      tr2.place.should == 2
      tr3.place.should == 3
      tr4.place.should == 4
      tr5.place.should == 5
      tr6.place.should == 6
    end
  end
end
