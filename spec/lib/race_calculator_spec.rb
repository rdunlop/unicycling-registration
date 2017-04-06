require 'spec_helper'

describe OrderedResultCalculator do
  def recalc(calc = @calc)
    Rails.cache.clear
    if @competition.has_age_group_entry_results?
      calc.update_age_group_results
    end
    calc.update_overall_results
    @tr1.try(:reload)
    @tr2.try(:reload)
    @tr3.try(:reload)
    @tr4.try(:reload)
  end

  describe "when calculating the placing of timed races" do
    before(:each) do
      @event_configuration = FactoryGirl.create(:event_configuration, start_date: Date.today)
      @event = FactoryGirl.create(:event)
      @age_group_entry = FactoryGirl.create(:age_group_entry) # 0-100 age group
      @competition = FactoryGirl.create(:timed_competition, age_group_type: @age_group_entry.age_group_type, event: @event)
      FactoryGirl.create(:event_configuration, start_date: Date.new(2013, 1, 1))
      # Note: Registrants are born in 1990, thus are 22 years old
      @tr1 = FactoryGirl.create(:time_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
      @tr2 = FactoryGirl.create(:time_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
      @tr3 = FactoryGirl.create(:time_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
      @tr4 = FactoryGirl.create(:time_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition))

      @calc = OrderedResultCalculator.new(@competition)
    end

    describe "with a DQ and a non-DQ for the same competitor" do
      before :each do
        @tr1.update_attributes(status: "DQ", minutes: 0, seconds: 0, thousands: 0)
        @tr1b = FactoryGirl.create(:time_result, competitor: @tr1.competitor, minutes: 2, seconds: 3, thousands: 300)
      end

      it "should not consider the DQ to be the best time" do
        expect(@tr1.competitor.disqualified?).to be_falsy
        expect(@tr1.competitor.best_time_in_thousands).to eq(@tr1b.result)
      end
    end

    describe "with 2 age_groups" do
      before(:each) do
        @age_group_type = @age_group_entry.age_group_type
        @age_group_entry2 = FactoryGirl.create(:age_group_entry, age_group_type: @age_group_type, start_age: 50, end_age: 100, short_description: "50-100")
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
        travel 2.seconds do
          @reg.birthday = Date.today - 1.year
          @reg.contact_detail.responsible_adult_name = "Bob Smith"
          @reg.contact_detail.responsible_adult_phone = "911"
          @reg.save!
        end
        expect(@reg.age).to eq(1)

        # to burst the cache on Competitor#age
        travel 2.seconds do
          @reg = @tr2.competitor.registrants.first
          @reg.birthday = Date.today - 60.years
          @reg.save!
        end
        expect(@reg.age).to eq(60)

        @tr1.competitor.reload
        @tr2.competitor.reload
        # expect(@tr1.competitor.age_group_entry).not_to eq(@tr2.competitor.age_group_entry)

        recalc

        expect(@tr1.competitor.place).to eq(1) # not a tie, different groups
        expect(@tr2.competitor.place).to eq(1) # not a tie, different groups
      end
    end

    it "places everyone as DQ if they have no time" do
      recalc

      expect(@tr1.competitor.place_formatted).to eq("DQ")
      expect(@tr2.competitor.place_formatted).to eq("DQ")
      expect(@tr3.competitor.place_formatted).to eq("DQ")
      expect(@tr4.competitor.place_formatted).to eq("DQ")
    end

    it "places the first place as first" do
      @tr1.thousands = 1
      @tr1.save!

      recalc

      expect(@tr1.competitor.place).to eq(1)
    end

    it "places DQ's as 'DQ'" do
      @tr1.thousands = 1
      @tr1.status = "DQ"
      @tr1.save!

      recalc

      expect(@tr1.competitor.place_formatted).to eq("DQ")
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
        recalc

        expect(@tr1.competitor.place).to eq(2)
        expect(@tr2.competitor.place).to eq(1)
      end
      describe "when the first competitor is ineligible" do
        before(:each) do
          @reg = @tr2.competitor.registrants.first
          @reg.ineligible = true
          @reg.save!
          recalc
        end

        it "places the faster competitor first" do
          expect(@tr2.competitor.place).to eq(1)
        end
        it "places the slower competitor (eligible) as 1st also" do
          expect(@tr1.competitor.place).to eq(1)
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
        recalc

        expect(@tr1.competitor.place).to eq(1)
        expect(@tr2.competitor.place).to eq(1)
      end

      it "places slower score as 3rd place" do
        @tr3.minutes = 2
        @tr3.save!

        recalc

        expect(@tr3.competitor.place).to eq(3)
      end

      describe "if 3-way tie" do
        before(:each) do
          @tr3.minutes = 1
          @tr3.save!

          @tr4.minutes = 2
          @tr4.save!
        end

        it "ties 3 for first, and one for 4th" do
          recalc

          expect(@tr1.competitor.place).to eq(1)
          expect(@tr2.competitor.place).to eq(1)
          expect(@tr3.competitor.place).to eq(1)
          expect(@tr4.competitor.place).to eq(4)
        end
      end
    end
  end
  describe "when calculating multiple scores (bug)" do
    it "has increasing thousands" do
      @all_together = FactoryGirl.create(:age_group_type)
      FactoryGirl.create(:age_group_entry, age_group_type: @all_together, start_age: 0, end_age: 100, gender: "Male")
      @competition = FactoryGirl.create(:timed_competition, age_group_type: @all_together)
      travel 2.seconds do
        tr1 = FactoryGirl.create(:time_result, minutes: 1, seconds: 15, thousands: 935, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
        tr2 = FactoryGirl.create(:time_result, minutes: 1, seconds: 23, thousands: 97, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
        tr4 = FactoryGirl.create(:time_result, minutes: 1, seconds: 26, thousands: 745, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
        tr5 = FactoryGirl.create(:time_result, minutes: 1, seconds: 28, thousands: 498, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
        tr3 = FactoryGirl.create(:time_result, minutes: 1, seconds: 25, thousands: 206, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
        tr6 = FactoryGirl.create(:time_result, minutes: 1, seconds: 32, thousands: 508, competitor: FactoryGirl.create(:event_competitor, competition: @competition))
        tr7 = FactoryGirl.create(:time_result, minutes: 1, seconds: 32, thousands: 815, competitor: FactoryGirl.create(:event_competitor, competition: @competition))

        rc = OrderedResultCalculator.new(@competition)
        recalc(rc)

        expect(tr1.reload.competitor.place).to eq(1)
        expect(tr2.reload.competitor.place).to eq(2)
        expect(tr3.reload.competitor.place).to eq(3)
        expect(tr4.reload.competitor.place).to eq(4)
        expect(tr5.reload.competitor.place).to eq(5)
        expect(tr6.reload.competitor.place).to eq(6)
        expect(tr7.reload.competitor.place).to eq(7)
      end
    end
  end
end
