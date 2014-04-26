require 'spec_helper'

describe "combined_competition_entries/index" do
  before(:each) do
    assign(:combined_competition_entries, [
      stub_model(CombinedCompetitionEntry,
        :combined_competition_id => 1,
        :abbreviation => "Abbreviation",
        :tie_breaker => false,
        :points => 2
      ),
      stub_model(CombinedCompetitionEntry,
        :combined_competition_id => 1,
        :abbreviation => "Abbreviation",
        :tie_breaker => false,
        :points => 2
      )
    ])
  end

  it "renders a list of combined_competition_entries" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Abbreviation".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
