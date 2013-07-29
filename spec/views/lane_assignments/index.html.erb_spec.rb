require 'spec_helper'

describe "lane_assignments/index" do
  before(:each) do
    @competition = FactoryGirl.create(:competition)
    assign(:lane_assignments, 
      [FactoryGirl.create(:lane_assignment, :competition => @competition, :registrant => FactoryGirl.create(:competitor, :bib_number => 123), :heat => 3, :lane => 4),
      FactoryGirl.create(:lane_assignment, :competition => @competition, :registrant => FactoryGirl.create(:competitor, :bib_number => 234), :heat => 30, :lane => 40)])
    @lane_assignment = FactoryGirl.build(:lane_assignment)
  end

  it "renders a list of lane_assignments" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 123.to_s, :count => 1
    assert_select "tr>td", :text => 234.to_s, :count => 1
    assert_select "tr>td", :text => 3.to_s, :count => 1
    assert_select "tr>td", :text => 30.to_s, :count => 1
    assert_select "tr>td", :text => 4.to_s, :count => 1
    assert_select "tr>td", :text => 40.to_s, :count => 1
  end

  describe "lane_assignments/new" do
    before(:each) do
      assign(:lane_assignment, FactoryGirl.build(:lane_assignment, :competition => @competition))
    end

    it "renders new lane_assignment form" do
      render

      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => competition_lane_assignments_path(@competition), :method => "post" do
        assert_select "input#lane_assignment_registrant_id", :name => "lane_assignment[registrant_id]"
        assert_select "input#lane_assignment_heat", :name => "lane_assignment[heat]"
        assert_select "input#lane_assignment_lane", :name => "lane_assignment[lane]"
      end
    end
  end 
end
