require 'spec_helper'

describe "award_labels/edit" do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    @award_label = FactoryGirl.create(:award_label)
  end

  it "renders the edit award_label form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: award_label_path(@award_label), method: "put" do
      assert_select "input#award_label_bib_number", name: "award_label[bib_number]"
      assert_select "input#award_label_competitor_name", name: "award_label[competitor_name]"
      assert_select "input#award_label_competition_name", name: "award_label[competition_name]"
      assert_select "input#award_label_team_name", name: "award_label[team_name]"
      assert_select "input#award_label_category", name: "award_label[category]"
      assert_select "input#award_label_details", name: "award_label[details]"
      assert_select "input#award_label_place", name: "award_label[place]"
      assert_select "select#award_label_registrant_id", name: "award_label[registrant_id]"
    end
  end
end
