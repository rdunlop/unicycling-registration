require 'spec_helper'

describe "lane_assignments/index" do
  before(:each) do
    assign(:lane_assignments, [
      stub_model(LaneAssignment,
        :competition_id => 1,
        :bib_number => 2,
        :heat => 3,
        :lane => 4
      ),
      stub_model(LaneAssignment,
        :competition_id => 1,
        :bib_number => 2,
        :heat => 3,
        :lane => 4
      )
    ])
  end

  it "renders a list of lane_assignments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
