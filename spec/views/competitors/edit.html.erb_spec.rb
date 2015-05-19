require 'spec_helper'

describe "competitors/edit" do
  before(:each) do
    @c = FactoryGirl.create(:event_competitor)
    @judge = FactoryGirl.create(:judge, :competition => @c.competition)
    assign(:judge, @judge)
    assign(:judges, [])
    assign(:competitor, @c)
    @s = Score.last
    assign(:score, @s)
  end

  it "renders the edit score form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => competition_competitors_path(@c.competition, @c), :method => "post" do
      assert_select "input#competitor_custom_name", :name => "competitor[custom_name]"
    end
  end
end
