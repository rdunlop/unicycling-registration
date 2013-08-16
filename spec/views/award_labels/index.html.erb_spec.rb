require 'spec_helper'

describe "award_labels/index" do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    assign(:user, @user)
    assign(:award_labels, [
      FactoryGirl.create(:award_label,
        :bib_number => 123,
        :first_name => "Robin",
        :last_name => "Dunlop",
        :partner_first_name => "Connie",
        :partner_last_name => "Cotter",
        :competition_name => "Pairs Freestyle",
        :team_name => "TCUC",
        :age_group => "All",
        :gender => "(mixed)",
        :details => "Winner",
        :place => 2
      ),
      FactoryGirl.create(:award_label)])
    @award_label = FactoryGirl.build(:award_label)
  end

  it "renders a list of award_labels" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 123.to_s, :count => 1
    assert_select "tr>td", :text => "Robin Dunlop &amp; Connie Cotter".to_s, :count => 1
    assert_select "tr>td", :text => "Pairs Freestyle".to_s, :count => 1
    assert_select "tr>td", :text => "TCUC".to_s, :count => 1
    assert_select "tr>td", :text => "All".to_s, :count => 1
    assert_select "tr>td", :text => "Winner".to_s, :count => 1
    assert_select "tr>td", :text => "2nd Place".to_s, :count => 1
    assert_select "tr>td", :text => 2.to_s, :count => 1
  end
  describe "award_labels/new" do
    before(:each) do
      assign(:award_label, FactoryGirl.build(:award_label,
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
      ))
    end
  
    it "renders new award_label form" do
      render
  
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "form", :action => user_award_labels_path(@user), :method => "post" do
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
end
