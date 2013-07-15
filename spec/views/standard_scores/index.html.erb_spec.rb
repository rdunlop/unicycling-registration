require 'spec_helper'

describe "standard_scores/index" do

  it "renders successfully all competitors" do
    assign(:judge, FactoryGirl.create(:judge))
    c = FactoryGirl.create(:event_competitor)
    assign(:competitors, [c])
    r = c.registrants.first
    r.first_name = "Robin"
    r.save!

    render

    rendered.should match(/Robin/)
  end
end
