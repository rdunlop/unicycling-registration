require 'spec_helper'

describe "registrants/index" do
  describe "with no registrants" do
    before(:each) do
      @registrants = []
      @total_owing = 0
    end
    it "should not render the registrants list" do
      render
      assert_select "fieldset", :count => 0
    end
    it "should not render the amonut owing block" do
      render
      assert_select "div", :text => /Pay Now/, :count => 0
    end
  end

  describe "with 2 registrants" do
    before(:each) do
      assign(:registrants, [
        FactoryGirl.create(:registrant,
        :first_name => "Robin",
        :middle_initial => "A",
        :last_name => "Dunlop"
        ),
        FactoryGirl.create(:registrant,
        :first_name => "Caitlin",
        :middle_initial => "E",
        :last_name => "Goeres"
        )
      ])
      @total_owing = 40
    end

    it "renders a list of registrants" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      assert_select "a", :text => "Robin Dunlop".to_s, :count => 1
      assert_select "a", :text => "Caitlin Goeres".to_s, :count => 1
      assert_select "a", :text => "Pay Now ($40)".to_s, :count => 1
    end
  end
end
