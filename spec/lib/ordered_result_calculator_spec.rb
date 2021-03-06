require 'spec_helper'

describe OrderedResultCalculator do
  def recalc
    Rails.cache.clear
    if @competition.has_age_group_entry_results?
      @calc.update_age_group_results
    end
    @calc.update_overall_results
  end

  before do
    # Note: Registrants are born in 1990, thus are 22 years old
    FactoryBot.create(:event_configuration)
    @age_group_entry = FactoryBot.create(:age_group_entry) # 0-100 age group
    @competition = FactoryBot.create(:ranked_competition, age_group_type: @age_group_entry.age_group_type)
    @tr1 = FactoryBot.create(:external_result, competitor: FactoryBot.create(:event_competitor, competition: @competition), points: 1)
    @tr2 = FactoryBot.create(:external_result, competitor: FactoryBot.create(:event_competitor, competition: @competition), points: 2)
    @tr3 = FactoryBot.create(:external_result, competitor: FactoryBot.create(:event_competitor, competition: @competition), points: 3)
    @tr4 = FactoryBot.create(:external_result, competitor: FactoryBot.create(:event_competitor, competition: @competition), points: 4)
  end

  describe "without an age group" do
    before do
      @competition.age_group_type = nil
      @competition.save!
    end

    it "calculates the results the same" do
      @calc = described_class.new(@competition)
      recalc
      expect(@tr1.reload.competitor.overall_place).to eq(1)
      expect(@tr2.reload.competitor.overall_place).to eq(2)
      expect(@tr3.reload.competitor.overall_place).to eq(3)
      expect(@tr4.reload.competitor.overall_place).to eq(4)
    end
  end

  describe "when calculating the placing of lower-points-is-better races" do
    before do
      @calc = described_class.new(@competition)
    end

    it "sets the competitor places to same order as the points" do
      recalc

      expect(@tr1.reload.competitor.place).to eq(1)
      expect(@tr2.reload.competitor.place).to eq(2)
      expect(@tr3.reload.competitor.place).to eq(3)
      expect(@tr4.reload.competitor.place).to eq(4)
    end

    it "ignores competitors without scores" do
      @comp5 = FactoryBot.create(:event_competitor, competition: @competition)
      recalc
      expect(@tr1.reload.competitor.place).to eq(1)
      expect(@tr2.reload.competitor.place).to eq(2)
      expect(@tr3.reload.competitor.place).to eq(3)
      expect(@tr4.reload.competitor.place).to eq(4)
    end

    describe "with an ineligible registrant in first place" do
      before do
        r = @tr1.competitor.reload.members.first.registrant
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
      before do
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
    before do
      @calc = described_class.new(@competition, false)
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
