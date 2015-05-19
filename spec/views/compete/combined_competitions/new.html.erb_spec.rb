require 'spec_helper'

describe "compete/combined_competitions/new" do
  before(:each) do
    assign(:combined_competition, CombinedCompetition.new)
  end

  it "renders new combined_competition form" do
    render

    assert_select "form[action=?][method=?]", combined_competitions_path(:locale => :en), "post" do
      assert_select "input#combined_competition_name[name=?]", "combined_competition[name]"
    end
  end
end
