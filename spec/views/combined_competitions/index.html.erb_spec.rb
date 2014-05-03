require 'spec_helper'

describe "combined_competitions/index" do
  before(:each) do
    assign(:combined_competitions, [
      stub_model(CombinedCompetition,
        :name => "Name"
      ),
      stub_model(CombinedCompetition,
        :name => "Name"
      )
    ])
  end

  it "renders a list of combined_competitions" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
