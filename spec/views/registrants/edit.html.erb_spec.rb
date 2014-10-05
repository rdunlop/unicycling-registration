require 'spec_helper'

describe "registrants/edit" do
  before(:each) do
    @registrant = assign(:registrant, FactoryGirl.build_stubbed(:registrant))
    @categories = [FactoryGirl.create(:category)]
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
    controller.stub(:current_user) { FactoryGirl.create(:user) }
  end

  it "renders the edit registrant form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => registrants_path(@registrant), :method => "post" do
      assert_select "input#registrant_first_name", :name => "registrant[first_name]"
      assert_select "input#registrant_middle_initial", :name => "registrant[middle_initial]"
      assert_select "input#registrant_last_name", :name => "registrant[last_name]"
      assert_select "input#registrant_gender_male", :name => "registrant[gender]"
    end
  end
end
