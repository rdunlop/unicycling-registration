require 'spec_helper'

describe OrderedResultCalculator do
  def recalc
    Rails.cache.clear
    @calc.update_all_places
  end

  before(:each) do
    # Note: Registrants are born in 1990, thus are 22 years old
    FactoryGirl.create(:event_configuration, start_date: Date.new(2013, 01, 01))
    @age_group_entry = FactoryGirl.create(:age_group_entry) # 0-100 age group
    @competition = FactoryGirl.create(:ranked_competition, age_group_type: @age_group_entry.age_group_type)
    @tr1 = FactoryGirl.create(:external_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition), points: 1)
    @tr2 = FactoryGirl.create(:external_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition), points: 2)
    @tr3 = FactoryGirl.create(:external_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition), points: 3)
    @tr4 = FactoryGirl.create(:external_result, competitor: FactoryGirl.create(:event_competitor, competition: @competition), points: 4)
  end
  describe "without an age group" do
    before :each do
      @competition.age_group_type = nil
      @competition.save!
    end

    it "calculates the results the same" do
      @calc = OrderedResultCalculator.new(@competition)
      recalc
      expect(@tr1.reload.competitor.overall_place).to eq(1)
      expect(@tr2.reload.competitor.overall_place).to eq(2)
      expect(@tr3.reload.competitor.overall_place).to eq(3)
      expect(@tr4.reload.competitor.overall_place).to eq(4)
    end
  end

  describe "when calculating the placing of lower-points-is-better races" do
    before :each do
      @calc = OrderedResultCalculator.new(@competition)
    end

    it "sets the competitor places to same order as the points" do
      recalc

      expect(@tr1.reload.competitor.place).to eq(1)
      expect(@tr2.reload.competitor.place).to eq(2)
      expect(@tr3.reload.competitor.place).to eq(3)
      expect(@tr4.reload.competitor.place).to eq(4)
    end

    it "ignores competitors without scores" do
      @comp5 = FactoryGirl.create(:event_competitor, competition: @competition)
      recalc
      expect(@tr1.reload.competitor.place).to eq(1)
      expect(@tr2.reload.competitor.place).to eq(2)
      expect(@tr3.reload.competitor.place).to eq(3)
      expect(@tr4.reload.competitor.place).to eq(4)
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

        expect(@tr1.competitor.place).to eq(1)
        expect(@tr2.competitor.place).to eq(1)
        expect(@tr3.competitor.place).to eq(2)
      end
    end

    describe "with a disqualified registrant in first place" do
      before(:each) do
        comp = @tr1.competitor
        comp.status = "not_qualified"
        comp.save!
        @tr1.reload
      end
      it "places the first 2 competitors as first" do
        recalc
        @tr2.reload
        @tr3.reload

        expect(@tr1.competitor.place).to eq(1)
        expect(@tr2.competitor.place).to eq(1)
        expect(@tr3.competitor.place).to eq(2)
      end
    end
  end

  describe "when calculating the placing of higher-points-is-better races" do
    before :each do
      @calc = OrderedResultCalculator.new(@competition, false)
    end
    it "Sets the competitor places to the opposite of the points" do
      recalc

      expect(@tr1.reload.competitor.place).to eq(4)
      expect(@tr2.reload.competitor.place).to eq(3)
      expect(@tr3.reload.competitor.place).to eq(2)
      expect(@tr4.reload.competitor.place).to eq(1)
    end
  end
end
