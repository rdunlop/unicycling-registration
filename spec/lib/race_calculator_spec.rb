require 'spec_helper'

describe RaceCalculator do
  describe "when calculating the placing of timed races" do
    before(:each) do
      @event = FactoryGirl.create(:event)
      @event_category = @event.event_categories.first
      @tr1 = FactoryGirl.create(:time_result, :event_category => @event_category)
      @tr2 = FactoryGirl.create(:time_result, :event_category => @event_category)
      @tr3 = FactoryGirl.create(:time_result, :event_category => @event_category)
      @tr4 = FactoryGirl.create(:time_result, :event_category => @event_category)

      @calc = RaceCalculator.new(@event_category)
    end

    it "places everyone as 0 if they have no time" do
      @calc.update_places

      @tr1.place.should == 0
      @tr2.place.should == 0
      @tr3.place.should == 0
      @tr4.place.should == 0
    end

    it "places the first place as first" do
      @tr1.thousands = 1
      @tr1.save!

      @calc.update_places

      @tr1.place.should == 1
    end

    it "places DQ's as 0" do
      @tr1.thousands = 1
      @tr1.disqualified = true
      @tr1.save!

      @calc.update_places

      @tr1.place.should == 0
    end

    it "places fast times first" do
      @tr1.thousands = 0
      @tr1.seconds = 30
      @tr1.minutes = 3
      @tr1.save!

      # faster:
      @tr2.thousands = 120
      @tr2.seconds = 40
      @tr2.minutes = 2
      @tr2.save!

      @calc.update_places

      @tr1.place.should == 2
      @tr2.place.should == 1
    end

    describe "if 2 times are identical" do
      before(:each) do
        @tr1.minutes = 1
        @tr1.save!
        @tr2.minutes = 1
        @tr2.save!
      end
      it "ties for first" do
        @calc.update_places

        @tr1.place.should == 1
        @tr2.place.should == 1
      end

      it "places slower score as 3rd place" do
        @tr3.minutes = 2
        @tr3.save!

        @calc.update_places

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
          @calc.update_places

          @tr1.place.should == 1
          @tr2.place.should == 1
          @tr3.place.should == 1
          @tr4.place.should == 4
        end
      end
    end
  end
end
