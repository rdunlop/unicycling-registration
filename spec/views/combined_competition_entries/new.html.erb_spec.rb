require 'spec_helper'

describe "combined_competition_entries/new" do
  before(:each) do
    @combined_competition = FactoryGirl.build_stubbed(:combined_competition)
    @combined_competition_entry = CombinedCompetitionEntry.new
  end

  it "renders new combined_competition_entry form" do
    render

    assert_select "form[action=?][method=?]", combined_competition_combined_competition_entries_path(@combined_competition, :locale => :en), "post" do
      assert_select "input#combined_competition_entry_abbreviation[name=?]", "combined_competition_entry[abbreviation]"
      assert_select "input#combined_competition_entry_tie_breaker[name=?]", "combined_competition_entry[tie_breaker]"
      assert_select "input#combined_competition_entry_points_1[name=?]", "combined_competition_entry[points_1]"
      assert_select "select#combined_competition_entry_competition_id[name=?]", "combined_competition_entry[competition_id]"
    end
  end
end
