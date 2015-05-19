require 'spec_helper'

describe "compete/combined_competitions/edit" do
  before(:each) do
    @combined_competition = assign(:combined_competition, FactoryGirl.build_stubbed(:combined_competition))
  end

  it "renders the edit combined_competition form" do
    render

    assert_select "form[action=?][method=?]", combined_competition_path(@combined_competition, :locale => :en), "post" do
      assert_select "input#combined_competition_name[name=?]", "combined_competition[name]"
    end
  end
end
