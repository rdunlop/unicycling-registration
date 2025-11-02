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

  describe "when lots of competitors" do
    before do
      @calc = described_class.new(@competition)

      number_of_results_to_create = 1000
      start_time = Time.zone.now

      # Let's create our objects and then batch insert them to improve performances
      competitors = FactoryBot.build_list(:event_competitor, number_of_results_to_create, competition: @competition).map do |competitor|
        {
          competition_id: competitor.competition_id,
          position: competitor.position,
          custom_name: competitor.custom_name,
          created_at: competitor.created_at,
          updated_at: competitor.updated_at,
          status: competitor.status,
          lowest_member_bib_number: competitor.lowest_member_bib_number,
          geared: competitor.geared,
          riding_wheel_size: competitor.riding_wheel_size,
          notes: competitor.notes,
          wave: competitor.wave,
          riding_crank_size: competitor.riding_crank_size,
          withdrawn_at: competitor.withdrawn_at,
          tier_number: competitor.tier_number,
          tier_description: competitor.tier_description,
          age_group_entry_id: competitor.age_group_entry_id
        }
      end
      saved_competitors = Competitor.insert_all(competitors)
      results = FactoryBot.build_list(:external_result, number_of_results_to_create).map.with_index do |result, i|
        {
          competitor_id: saved_competitors.rows[i][0],
          details: result.details,
          points: i,
          created_at: result.created_at,
          updated_at: result.updated_at,
          entered_by_id: i,
          entered_at: result.entered_at,
          status: result.status,
          preliminary: result.preliminary
        }
      end
      ExternalResult.insert_all(results)

      end_time = Time.zone.now
      p "Init duration: #{end_time - start_time}"
    end

    it "takes less than 10 seconds" do
      start_time = Time.zone.now
      @calc = described_class.new(@competition)
      recalc
      end_time = Time.zone.now

      total_duration = end_time - start_time
      p "Total duration: #{total_duration}"

      expect(total_duration).to be <= 10
    end
  end
end
