require 'spec_helper'

describe "standard_skill_entries/index" do
  it "should display all present skills" do
    assign(:standard_skill_entries, [FactoryGirl.create(:standard_skill_entry, description: "first skill")])
    render

    expect(rendered).to match(/first skill/)
  end
end
