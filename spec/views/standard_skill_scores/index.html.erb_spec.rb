require 'spec_helper'

describe "standard_skill_scores/index" do
  it "renders successfully all competitors" do
    assign(:judge, FactoryGirl.create(:judge))
    c = FactoryGirl.create(:event_competitor)
    FactoryGirl.create(:standard_skill_routine, registrant: c.registrants.first)
    assign(:competitors, [c])
    r = c.registrants.first
    r.first_name = "Robin"
    r.save!

    render

    expect(rendered).to match(/Robin/)
  end
end
