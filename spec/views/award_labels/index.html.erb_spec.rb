require 'spec_helper'

describe "award_labels/index" do
  before(:each) do
    assign(:award_labels, [
      stub_model(AwardLabel,
        :bib_number => 1,
        :first_name => "First Name",
        :last_name => "Last Name",
        :partner_first_name => "Partner First Name",
        :partner_last_name => "Partner Last Name",
        :competition_name => "Competition Name",
        :team_name => "Team Name",
        :age_group => "Age Group",
        :gender => "Gender",
        :details => "Details",
        :place => 2,
        :user_id => 3,
        :registrant_id => 4
      ),
      stub_model(AwardLabel,
        :bib_number => 1,
        :first_name => "First Name",
        :last_name => "Last Name",
        :partner_first_name => "Partner First Name",
        :partner_last_name => "Partner Last Name",
        :competition_name => "Competition Name",
        :team_name => "Team Name",
        :age_group => "Age Group",
        :gender => "Gender",
        :details => "Details",
        :place => 2,
        :user_id => 3,
        :registrant_id => 4
      )
    ])
  end

  it "renders a list of award_labels" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Partner First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Partner Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "Competition Name".to_s, :count => 2
    assert_select "tr>td", :text => "Team Name".to_s, :count => 2
    assert_select "tr>td", :text => "Age Group".to_s, :count => 2
    assert_select "tr>td", :text => "Gender".to_s, :count => 2
    assert_select "tr>td", :text => "Details".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
