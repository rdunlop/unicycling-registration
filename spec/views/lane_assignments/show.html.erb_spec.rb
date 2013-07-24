require 'spec_helper'

describe "lane_assignments/show" do
  before(:each) do
    @lane_assignment = assign(:lane_assignment, stub_model(LaneAssignment,
      :competition_id => 1,
      :bib_number => 2,
      :heat => 3,
      :lane => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
