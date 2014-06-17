require 'spec_helper'

describe OrderedResultCalculator do
  def recalc
    Rails.cache.clear
    @calc.update_all_places
  end

  describe "when calculating the placing of externally-ranked races" do
    before(:each) do
      @event_configuration = FactoryGirl.create(:event_configuration, :start_date => Date.today)
      @event = FactoryGirl.create(:event)
      @age_group_entry = FactoryGirl.create(:age_group_entry) # 0-100 age group
      @competition = FactoryGirl.create(:ranked_competition, :age_group_type => @age_group_entry.age_group_type, :event => @event)
      FactoryGirl.create(:event_configuration, :start_date => Date.new(2013,01,01))
      # Note: Registrants are born in 1990, thus are 22 years old
      @tr1 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :points => 1)
      @tr2 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :points => 2)
      @tr3 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :points => 3)
      @tr4 = FactoryGirl.create(:external_result, :competitor => FactoryGirl.create(:event_competitor, :competition => @competition), :points => 4)

      @calc = OrderedResultCalculator.new(@competition)
    end
    it "sets the competitor places to the ranks" do
      recalc

      @tr1.reload.competitor.place.should == 1
      @tr2.reload.competitor.place.should == 2
      @tr3.reload.competitor.place.should == 3
      @tr4.reload.competitor.place.should == 4
    end

    describe "with an ineligible registrant in first place" do
      before(:each) do
        r = @tr1.competitor.members(true).first.registrant
        r.ineligible = true
        r.save!
        @tr1.reload
      end
      it "places the first 2 competitors as first" do
        recalc
        @tr2.reload
        @tr3.reload

        @tr1.competitor.place.should == 1
        @tr2.competitor.place.should == 1
        @tr3.competitor.place.should == 2
      end
    end
  end

end

