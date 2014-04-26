require 'spec_helper'

describe "combined_competition_entries/edit" do
  before(:each) do
    @combined_competition_entry = assign(:combined_competition_entry, stub_model(CombinedCompetitionEntry,
      :combined_competition_id => 1,
      :abbreviation => "MyString",
      :tie_breaker => false,
      :points => 1
    ))
  end

  it "renders the edit combined_competition_entry form" do
    render

    assert_select "form[action=?][method=?]", combined_competition_entry_path(@combined_competition_entry), "post" do
      assert_select "input#combined_competition_entry_combined_competition_id[name=?]", "combined_competition_entry[combined_competition_id]"
      assert_select "input#combined_competition_entry_abbreviation[name=?]", "combined_competition_entry[abbreviation]"
      assert_select "input#combined_competition_entry_tie_breaker[name=?]", "combined_competition_entry[tie_breaker]"
      assert_select "input#combined_competition_entry_points[name=?]", "combined_competition_entry[points]"
    end
  end
end
