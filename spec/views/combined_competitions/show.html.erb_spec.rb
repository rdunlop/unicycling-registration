require 'spec_helper'

describe "combined_competitions/show" do
  before(:each) do
    @combined_competition = assign(:combined_competition, stub_model(CombinedCompetition,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
