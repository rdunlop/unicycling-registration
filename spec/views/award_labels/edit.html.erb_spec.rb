require 'spec_helper'

describe "award_labels/edit" do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    @award_label = FactoryGirl.create(:award_label,
      :bib_number => 1,
      :first_name => "MyString",
      :last_name => "MyString",
      :partner_first_name => "MyString",
      :partner_last_name => "MyString",
      :competition_name => "MyString",
      :team_name => "MyString",
      :age_group => "MyString",
      :gender => "MyString",
      :details => "MyString",
      :place => 1,
      :registrant_id => 1
    )
  end

  it "renders the edit award_label form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => award_label_path(@award_label), :method => "put" do
      assert_select "input#award_label_bib_number", :name => "award_label[bib_number]"
      assert_select "input#award_label_first_name", :name => "award_label[first_name]"
      assert_select "input#award_label_last_name", :name => "award_label[last_name]"
      assert_select "input#award_label_partner_first_name", :name => "award_label[partner_first_name]"
      assert_select "input#award_label_partner_last_name", :name => "award_label[partner_last_name]"
      assert_select "input#award_label_competition_name", :name => "award_label[competition_name]"
      assert_select "input#award_label_team_name", :name => "award_label[team_name]"
      assert_select "input#award_label_age_group", :name => "award_label[age_group]"
      assert_select "input#award_label_gender", :name => "award_label[gender]"
      assert_select "input#award_label_details", :name => "award_label[details]"
      assert_select "input#award_label_place", :name => "award_label[place]"
      assert_select "select#award_label_registrant_id", :name => "award_label[registrant_id]"
    end
  end
end
