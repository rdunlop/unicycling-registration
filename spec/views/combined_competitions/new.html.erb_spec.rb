require 'spec_helper'

describe "combined_competitions/new" do
  before(:each) do
    assign(:combined_competition, stub_model(CombinedCompetition,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new combined_competition form" do
    render

    assert_select "form[action=?][method=?]", combined_competitions_path, "post" do
      assert_select "input#combined_competition_name[name=?]", "combined_competition[name]"
    end
  end
end
