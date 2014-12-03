require 'spec_helper'

describe CombinedCompetitionResult do
  def build_competitor(options = {})
    competition = (options[:competition]) || FactoryGirl.create(:competition)
    reg = FactoryGirl.create(:registrant, bib_number: options[:bib_number], gender: "Male")
    comp = FactoryGirl.create(:event_competitor, competition: competition)
    FactoryGirl.create(:result, competitor: comp, place: options[:place], result_type: "Overall")
    mem = comp.members.first
    mem.registrant = reg
    Delorean.jump 2
    mem.save!
    FactoryGirl.create(:time_result, competitor: comp)
    comp
  end

  let(:race_100m) { FactoryGirl.create(:timed_competition) }
  let(:combined_competition) { FactoryGirl.create(:combined_competition) }
  let(:combined_competition_result) { CombinedCompetitionResult.new(combined_competition).results("Male") }
  let(:combined_competition_entry) { FactoryGirl.create(:combined_competition_entry, combined_competition: combined_competition, :abbreviation => "TT", competition: race_100m) }

  before(:each) do
    build_competitor(:place => 1, :bib_number => 10, competition: combined_competition_entry.competition)
  end

  it "lists competitors" do
    expect(combined_competition_result.length).to eq(1)
  end

  it "lists the first place details" do
    result_1 = combined_competition_result
    expect(result_1).to eq([{:bib_number => 10, :results => {"TT" => { :entry_place => 1, :entry_points => 50 } }, :total_points => 50 }])
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

#   10 - Robin - M - 2nd (35)   TT - 1st (39)   Crit - 10th (1) Total (75)   ( has more firsts)
#   20 - Scott - M - 2nd (35)   TT - 2nd (28)   Crit - 2nd (12) Total (75)
#   30 - Jim   - M - 1st (50)   TT - 5th (18)   Crit - 5th (7)  Total (75)
#
#   #Results:
#   1 - Jim   (1 first, 1st in tie-breaker (M))
#   2 - Robin (1 first)
#   3 - Scott (0 first)
def configure_cce(combined_competition_entry, options = {})
  allow(combined_competition_entry).to receive("points_#{options[:place]}".to_sym).and_return(options[:points])
end
  describe "when there is a tie" do
    before(:each) do
      competition1 = FactoryGirl.build_stubbed(:competition)
      competition2 = FactoryGirl.build_stubbed(:competition)
      competition3 = FactoryGirl.build_stubbed(:competition)
      competitor1m    = build_competitor(:place => 2, :bib_number => 10, competition: competition1)
      competitor1tt   = build_competitor(:place => 1, :bib_number => 10, competition: competition2)
      competitor1crit = build_competitor(:place => 10, :bib_number => 10,competition: competition3)
      competitor2m    = build_competitor(:place => 2, :bib_number => 20, competition: competition1)
      competitor2tt   = build_competitor(:place => 2, :bib_number => 20, competition: competition2)
      competitor2crit = build_competitor(:place => 2, :bib_number => 20, competition: competition3)
      competitor3m    = build_competitor(:place => 1, :bib_number => 30, competition: competition1)
      competitor3tt   = build_competitor(:place => 5, :bib_number => 30, competition: competition2)
      competitor3crit = build_competitor(:place => 5, :bib_number => 30, competition: competition3)
      m_combined_competition_entry = FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "M", :tie_breaker => true, competition: competition1)
      #allow(competitor1m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      #allow(competitor2m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      #allow(competitor3m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      tt_combined_competition_entry = FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "TT", :tie_breaker => false, competition: competition2)
      #allow(competitor1tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      #allow(competitor2tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      #allow(competitor3tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      crit_combined_competition_entry = FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "Crit", :tie_breaker => false, competition: competition3)
      #allow(competitor1crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      #allow(competitor2crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      #allow(competitor3crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      configure_cce(m_combined_competition_entry, :place => 2, :points => 35)
      configure_cce(m_combined_competition_entry, :place => 1, :points => 50)
      configure_cce(tt_combined_competition_entry, :place => 1, :points => 39)
      configure_cce(tt_combined_competition_entry, :place => 2, :points => 28)
      configure_cce(tt_combined_competition_entry, :place => 5, :points => 18)
      configure_cce(crit_combined_competition_entry, :place => 10, :points => 1)
      configure_cce(crit_combined_competition_entry, :place => 2, :points => 12)
      configure_cce(crit_combined_competition_entry, :place => 5, :points => 7)
      allow(m_combined_competition_entry).to receive(:competitors).and_return([competitor1m, competitor2m, competitor3m])
      allow(tt_combined_competition_entry).to receive(:competitors).and_return([competitor1tt, competitor2tt, competitor3tt])
      allow(crit_combined_competition_entry).to receive(:competitors).and_return([competitor1crit, competitor2crit, competitor3crit])
      allow(combined_competition).to receive(:combined_competition_entries).and_return([m_combined_competition_entry, tt_combined_competition_entry, crit_combined_competition_entry])
      allow(combined_competition).to receive(:tie_breaker_competition).and_return(competition1)
    end

    xit "lists the 3 places" do
      result_1 = combined_competition_result
      expect(result_1.length).to eq(3)
      expect(result_1[0][:place]).to eq(1)
      expect(result_1[0][:bib_number]).to eq(30)
      expect(result_1[1][:place]).to eq(2)
      expect(result_1[1][:bib_number]).to eq(10)
      expect(result_1[2][:place]).to eq(3)
      expect(result_1[2][:bib_number]).to eq(20)
    end
  end
end

describe CombinedCompetitionResult do
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
end
