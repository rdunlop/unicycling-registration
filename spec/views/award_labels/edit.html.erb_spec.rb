require 'spec_helper'

describe "award_labels/edit" do
  before(:each) do
    @user = FactoryGirl.create(:award_admin_user)
    @award_label = FactoryGirl.create(:award_label)
  end

  it "renders the edit award_label form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: award_label_path(@award_label), method: "put" do
      assert_select "input#award_label_bib_number", name: "award_label[bib_number]"
      assert_select "input#award_label_line_1", name: "award_label[line_1]"
      assert_select "input#award_label_line_2", name: "award_label[line_2]"
      assert_select "input#award_label_line_3", name: "award_label[line_3]"
      assert_select "input#award_label_line_4", name: "award_label[line_4]"
      assert_select "input#award_label_line_5", name: "award_label[line_5]"
      assert_select "input#award_label_place", name: "award_label[place]"
      assert_select "select#award_label_registrant_id", name: "award_label[registrant_id]"
    end
  end
end
