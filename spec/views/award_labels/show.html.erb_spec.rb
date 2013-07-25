require 'spec_helper'

describe "award_labels/show" do
  before(:each) do
    @award_label = assign(:award_label, stub_model(AwardLabel,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/First Name/)
    rendered.should match(/Last Name/)
    rendered.should match(/Partner First Name/)
    rendered.should match(/Partner Last Name/)
    rendered.should match(/Competition Name/)
    rendered.should match(/Team Name/)
    rendered.should match(/Age Group/)
    rendered.should match(/Gender/)
    rendered.should match(/Details/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
  end
end
