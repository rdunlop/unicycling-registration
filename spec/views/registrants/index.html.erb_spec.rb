require 'spec_helper'

describe "registrants/index" do
  before(:each) do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  describe "with no registrants" do
    before(:each) do
      @my_registrants = []
      @shared_registrants = []
    end
    it "should not render the registrants list" do
      render
      assert_select "legend", :text => "Registrations", :count => 0
    end
    it "should not render the amonut owing block" do
      render
      assert_select "div", :text => /Pay Now/, :count => 0
    end
  end

  describe "with 2 registrants" do
    before(:each) do
      @my_registrants = [
        FactoryGirl.create(:registrant, :first_name => "Robin", :last_name => "Dunlop"),
        FactoryGirl.create(:registrant, :first_name => "Caitlin", :last_name => "Goeres")]
      @shared_registrants = []
      @exp = FactoryGirl.create(:registrant_expense_item, :registrant => @my_registrants[0])
    end
    it "should render the registrants list" do
      render
      assert_select "legend", :text => "Registrations", :count => 1
    end

    it "renders a list of registrants" do
      @ability.can :create, Payment
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "a", :text => "Robin Dunlop".to_s, :count => 1
      assert_select "a", :text => "Caitlin Goeres".to_s, :count => 1
      assert_select "a", :text => "Pay Now".to_s, :count => 1
    end
  end
end
