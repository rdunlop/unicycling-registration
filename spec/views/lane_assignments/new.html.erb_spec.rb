require 'spec_helper'

describe "lane_assignments/new" do
  before(:each) do
    assign(:lane_assignment, stub_model(LaneAssignment,
      :competition_id => 1,
      :bib_number => 1,
      :heat => 1,
      :lane => 1
    ).as_new_record)
  end

  it "renders new lane_assignment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => lane_assignments_path, :method => "post" do
      assert_select "input#lane_assignment_competition_id", :name => "lane_assignment[competition_id]"
      assert_select "input#lane_assignment_bib_number", :name => "lane_assignment[bib_number]"
      assert_select "input#lane_assignment_heat", :name => "lane_assignment[heat]"
      assert_select "input#lane_assignment_lane", :name => "lane_assignment[lane]"
    end
  end
end
