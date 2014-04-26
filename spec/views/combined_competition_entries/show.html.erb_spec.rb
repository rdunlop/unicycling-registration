require 'spec_helper'

describe "combined_competition_entries/show" do
  before(:each) do
    @combined_competition_entry = assign(:combined_competition_entry, stub_model(CombinedCompetitionEntry,
      :combined_competition_id => 1,
      :abbreviation => "Abbreviation",
      :tie_breaker => false,
      :points => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Abbreviation/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/2/)
  end
end
