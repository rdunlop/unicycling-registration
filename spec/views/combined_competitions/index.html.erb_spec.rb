require 'spec_helper'

describe "combined_competitions/index" do
  before(:each) do
    assign(:combined_competitions, [
      FactoryGirl.build_stubbed(:combined_competition, name: "Name1"),
      FactoryGirl.build_stubbed(:combined_competition, name: "Name2")])
  end

  it "renders a list of combined_competitions" do
    render
    assert_select "tr>td", :text => "Name1".to_s, :count => 1
    assert_select "tr>td", :text => "Name2".to_s, :count => 1
  end
end
