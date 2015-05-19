require 'spec_helper'

describe "competitors/new" do
  before(:each) do
    registrant = FactoryGirl.create(:competitor)
    comp = assign(:competitor, FactoryGirl.build(:event_competitor))
    @ec = comp.competition
    assign(:competition, @ec)
    assign(:filtered_registrants, [registrant])
  end

  it "renders new competitor form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => new_competition_competitor_path(@ec), :method => "post" do
      assert_select "input#competitor_custom_name", :name => "competitor[custom_name]"
    end
  end
end
