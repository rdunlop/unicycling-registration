require 'spec_helper'

describe OverallChampionResultCalculator do
  def build_competitor(options = {})
    competition = (options[:competition]) || FactoryGirl.create(:competition)
    reg = FactoryGirl.create(:registrant, bib_number: options[:bib_number], gender: "Male")
    comp = FactoryGirl.create(:event_competitor, competition: competition)
    FactoryGirl.create(:result, competitor: comp, place: options[:place], result_type: "Overall")
    mem = comp.members.first
    mem.registrant = reg
    Delorean.jump 2
    mem.save!
    FactoryGirl.create(:time_result, competitor: comp, minutes: 1)
    comp
  end

  let(:race_100m) { FactoryGirl.create(:timed_competition) }
  let(:combined_competition) { FactoryGirl.create(:combined_competition) }
  let(:combined_competition_result) { described_class.new(combined_competition).results("Male") }
  let(:combined_competition_entry) { FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition, abbreviation: "TT", competition: race_100m) }

  before(:each) do
    build_competitor(place: 1, bib_number: 10, competition: combined_competition_entry.competition)
  end

  it "lists competitors" do
    expect(combined_competition_result.length).to eq(1)
  end

  it "lists the first place details" do
    result_1 = combined_competition_result
    expect(result_1).to eq([{bib_number: 10, results: {"TT" => { entry_place: 1, entry_points: 50 } }, total_points: 50, display_points: 50 }])
  end

  describe "with a tie-breaker" do
    before { combined_competition_entry.update_attribute(:tie_breaker, true) }

    before do
      build_competitor(place: 1, bib_number: 20, competition: combined_competition_entry.competition)
    end

    it "calculates results" do
      expect(combined_competition_result.length).to eq(2)
    end
  end

  #   10 - Robin - M - 2nd (35)   TT - 1st (39)   Crit - 10th (1) Total (75) ( has 2 firsts)
  #   20 - Scott - M - 2nd (35)   TT - 2nd (28)   Crit - 1st (12) Total (75) ( has 1 first)
  #   30 - Jim   - M - 1st (50)   TT - 5th (18)   Crit - 5th (7)  Total (75) ( has 1 first, and 1st in tie-breaker
  #
  #   #Results:
  #   1 - 10 - Robin (2 firsts)
  #   2 - 30 - Jim (1 first, but first in the tie-breaker)
  #   3 - 20 - Scott (1 first)
  def configure_cce(combined_competition_entry, options = {})
    combined_competition_entry.update_attribute("points_#{options[:place]}".to_sym, options[:points])
    # allow(combined_competition_entry).to receive("points_#{options[:place]}".to_sym).and_return(options[:points])
  end

  describe "when there is a tie" do
    before(:each) do
      competition1 = FactoryGirl.create(:competition)
      competition2 = FactoryGirl.create(:competition)
      competition3 = FactoryGirl.create(:competition)
      competitor1m    = build_competitor(place: 2, bib_number: 10, competition: competition1)
      competitor1tt   = build_competitor(place: 1, bib_number: 10, competition: competition2)
      competitor1crit = build_competitor(place: 10, bib_number: 10, competition: competition3)
      competitor2m    = build_competitor(place: 2, bib_number: 20, competition: competition1)
      competitor2tt   = build_competitor(place: 2, bib_number: 20, competition: competition2)
      competitor2crit = build_competitor(place: 1, bib_number: 20, competition: competition3)
      competitor3m    = build_competitor(place: 1, bib_number: 30, competition: competition1)
      competitor3tt   = build_competitor(place: 5, bib_number: 30, competition: competition2)
      competitor3crit = build_competitor(place: 5, bib_number: 30, competition: competition3)
      m_combined_competition_entry = FactoryGirl.create(:combined_competition_entry, abbreviation: "M", tie_breaker: true, competition: competition1, combined_competition: combined_competition)
      # allow(competitor1m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      # allow(competitor2m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      # allow(competitor3m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      tt_combined_competition_entry = FactoryGirl.create(:combined_competition_entry, abbreviation: "TT", tie_breaker: false, competition: competition2, combined_competition: combined_competition)
      # allow(competitor1tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      # allow(competitor2tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      # allow(competitor3tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      crit_combined_competition_entry = FactoryGirl.create(:combined_competition_entry, abbreviation: "Crit", tie_breaker: false, competition: competition3, combined_competition: combined_competition)
      # allow(competitor1crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      # allow(competitor2crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      # allow(competitor3crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      configure_cce(m_combined_competition_entry, place: 2, points: 35)
      configure_cce(m_combined_competition_entry, place: 1, points: 50)
      configure_cce(tt_combined_competition_entry, place: 1, points: 39)
      configure_cce(tt_combined_competition_entry, place: 2, points: 28)
      configure_cce(tt_combined_competition_entry, place: 5, points: 18)
      configure_cce(crit_combined_competition_entry, place: 10, points: 1)
      configure_cce(crit_combined_competition_entry, place: 1, points: 12)
      configure_cce(crit_combined_competition_entry, place: 5, points: 7)
      # allow(m_combined_competition_entry).to receive(:competitors).and_return([competitor1m, competitor2m, competitor3m])
      # allow(tt_combined_competition_entry).to receive(:competitors).and_return([competitor1tt, competitor2tt, competitor3tt])
      # allow(crit_combined_competition_entry).to receive(:competitors).and_return([competitor1crit, competitor2crit, competitor3crit])
      # allow(combined_competition).to receive(:combined_competition_entries).and_return([m_combined_competition_entry, tt_combined_competition_entry, crit_combined_competition_entry])
      # allow(combined_competition).to receive(:tie_breaker_competition).and_return(competition1)
    end

    it "lists the 3 places" do
      result_1 = combined_competition_result
      expect(result_1.length).to eq(3)
      res_10 = result_1.detect{ |res| res[:bib_number] == 10 }
      res_20 = result_1.detect{ |res| res[:bib_number] == 20 }
      res_30 = result_1.detect{ |res| res[:bib_number] == 30 }

      expect(res_10[:display_points]).to eq(75.0)
      expect(res_10[:total_points]).to eq(75.0)
      expect(res_10[:bib_number]).to eq(10)

      expect(res_30[:display_points]).to eq(75.0)
      expect(res_30[:total_points]).to eq(74.9)
      expect(res_30[:bib_number]).to eq(30)

      expect(res_20[:display_points]).to eq(75.0)
      expect(res_20[:total_points]).to eq(74.89)
      expect(res_20[:bib_number]).to eq(20)
    end
  end
end

describe OverallChampionResultCalculator do
  let(:combined_competition) { FactoryGirl.build_stubbed :combined_competition, percentage_based_calculations: true }
  let(:result) { described_class.new(combined_competition) }

  context "calculate the number of points by percentage calculation" do
    context "when I am in first place" do
      specify { expect(result.calc_perc_points(best_time: 300, time: 300, base_points: 50, bonus_percentage: 20)).to eq(60) }
    end
    context "when I am in second place" do
      specify { expect(result.calc_perc_points(best_time: 300, time: 330, base_points: 50, bonus_percentage: 10)).to be_within(0.1).of(50) }
    end
  end

  it "adjusts points by number of firsts" do
    score = 10
    bib_numbers = [3, 2]
    firsts_counts = { 3 => 1, 2 => 0}

    expected_hash = { 10 => [3], 9.9 => [2] }
    expect(result.adjust_ties_by_firsts(score, bib_numbers, firsts_counts)).to eq(expected_hash)
  end

  it "adjusts the scores based on the number of firsts ties" do
    gender = "Male"
    initial_scores = {
      10 => [1, 2, 3],
      11 => [5],
    }
    expected_hash = {
      10 => [3],
      9.9 => [1, 2],
      11 => [5],
    }
    allow(result).to receive(:num_firsts).with("Male", 1).and_return(1)
    allow(result).to receive(:num_firsts).with("Male", 2).and_return(1)
    allow(result).to receive(:num_firsts).with("Male", 3).and_return(3)
    allow(result).to receive(:num_firsts).with("Male", 5).and_return(0)
    expect(result.break_ties_by_num_firsts(gender, initial_scores)).to eq(expected_hash)
  end

  it "calculates tie break adjustments by tie breakers" do
    gender = "Male"
    score = 10
    bib_numbers = [1, 2, 3]

    expected_array = [
      [9.99, 1],
      [9.98, 2],
      [10, 3]
    ]

    allow(result).to receive(:place_of_tie_breaker).with("Male", 1).and_return(2)
    allow(result).to receive(:place_of_tie_breaker).with("Male", 2).and_return(3)
    allow(result).to receive(:place_of_tie_breaker).with("Male", 3).and_return(1)
    expect(result.tie_breaking_scores(gender, score, bib_numbers)).to match_array(expected_array)
  end
end
