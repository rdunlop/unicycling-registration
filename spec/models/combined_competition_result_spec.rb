require 'spec_helper'

describe CombinedCompetitionResult do
  def build_competitor(options = {})
    competition = (options[:competition]) || FactoryGirl.build_stubbed(:competition)
    comp = FactoryGirl.build_stubbed(:event_competitor, competition: competition)
    allow(comp).to receive(:overall_place).and_return(options[:place])
    allow(comp).to receive(:has_result?).and_return(true)
    allow(comp).to receive(:gender).and_return("Male")
    reg = FactoryGirl.build_stubbed(:registrant)
    allow(reg).to receive(:bib_number).and_return(options[:bib_number])
    allow(comp).to receive_message_chain(:registrants, :first).and_return(reg)
    allow(Registrant).to receive(:find_by).and_return(reg)
    allow(reg).to receive(:ineligible).and_return(false)
    comp
  end

  let(:combined_competition) { FactoryGirl.create(:combined_competition) }
  let(:combined_competition_result) { CombinedCompetitionResult.new(combined_competition, "Male").results }
  let(:combined_competition_entry) { FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "TT") }

  before(:each) do
    competitor = build_competitor(:place => 1, :bib_number => 10, competition: combined_competition_entry.competition)
    allow(combined_competition_entry).to receive(:competitors).and_return([competitor])
    allow(combined_competition).to receive(:combined_competition_entries).and_return([combined_competition_entry])
  end

  it "lists competitors" do
    expect(combined_competition_result.length).to eq(1)
  end

  it "lists the first place details" do
    result_1 = combined_competition_result
    expect(result_1).to eq([{:place => 1, :bib_number => 10, :results => {"TT" => { :entry_place => 1, :entry_points => 50 } }, :total_points => 50 }])
  end

=begin
  #10 - Robin - M - 2nd (35)   TT - 1st (39)   Crit - 10th (1) Total (75)   ( has more firsts)
  #20 - Scott - M - 2nd (35)   TT - 2nd (28)   Crit - 2nd (12) Total (75)
  #30 - Jim   - M - 1st (50)   TT - 5th (18)   Crit - 5th (7)  Total (75)
  #
  #Results:
  # 1 - Jim   (1 first, 1st in tie-breaker (M))
  # 2 - Robin (1 first)
  # 3 - Scott (0 first)
=end
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
      m_combined_competition_entry = FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "M", :tie_breaker => true)
      allow(competitor1m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      allow(competitor2m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      allow(competitor3m).to receive_message_chain(:competition, :combined_competition_entries).and_return([m_combined_competition_entry])
      tt_combined_competition_entry = FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "TT", :tie_breaker => false)
      allow(competitor1tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      allow(competitor2tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      allow(competitor3tt).to receive_message_chain(:competition, :combined_competition_entries).and_return([tt_combined_competition_entry])
      crit_combined_competition_entry = FactoryGirl.build_stubbed(:combined_competition_entry, :abbreviation => "Crit", :tie_breaker => false)
      allow(competitor1crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      allow(competitor2crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
      allow(competitor3crit).to receive_message_chain(:competition, :combined_competition_entries).and_return([crit_combined_competition_entry])
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
