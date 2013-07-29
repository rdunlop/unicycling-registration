require 'spec_helper'

describe "lane_assignments/edit" do
  before(:each) do
    @lane_assignment = assign(:lane_assignment, FactoryGirl.create(:lane_assignment))
  end

  it "renders the edit lane_assignment form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => lane_assignment_path(@lane_assignment), :method => "post" do
      assert_select "input#lane_assignment_bib_number", :name => "lane_assignment[bib_number]"
      assert_select "input#lane_assignment_heat", :name => "lane_assignment[heat]"
      assert_select "input#lane_assignment_lane", :name => "lane_assignment[lane]"
    end
  end
end
