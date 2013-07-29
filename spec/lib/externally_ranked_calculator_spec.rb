require 'spec_helper'

describe ExternallyRankedCalculator do
  describe "when calculating the placing of externally-ranked races" do
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
      @tr1 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :rank => 1)
      @tr2 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :rank => 2)
      @tr3 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :rank => 3)
      @tr4 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :rank => 4)

      @calc = ExternallyRankedCalculator.new(@competition)
    end
    it "sets the competitor places to the ranks" do
      @calc.update_all_places

      @tr1.competitor.place.should == 1
      @tr2.competitor.place.should == 2
      @tr3.competitor.place.should == 3
      @tr4.competitor.place.should == 4
    end

    describe "with an ineligible registrant in first place" do
      before(:each) do
        r = @tr1.competitor.members(true).first.registrant
        r.ineligible = true
        r.save!
      end
      it "places the first 2 competitors as first" do
        @calc.update_all_places

        @tr1.competitor.place.should == 1
        @tr2.competitor.place.should == 1
        @tr3.competitor.place.should == 2
      end
    end
  end

end

