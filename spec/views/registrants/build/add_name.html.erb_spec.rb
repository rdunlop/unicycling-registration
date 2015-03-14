require 'spec_helper'

describe "registrants/build/add_name" do
  before(:each) do
    @comp_exp = FactoryGirl.create(:expense_item, :cost => 100)
    @noncomp_exp = FactoryGirl.create(:expense_item, :cost => 50)
    @registration_period = FactoryGirl.create(:registration_period,
                                              :start_date => Date.new(2012, 01, 10),
                                              :end_date => Date.new(2012, 02, 11),
                                              :competitor_expense_item => @comp_exp,
                                              :noncompetitor_expense_item => @noncomp_exp)
    FactoryGirl.create(:wheel_size_24, id: 3)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
    controller.stub(:current_user) { FactoryGirl.create(:user) }
    allow(view).to receive(:wizard_path).and_return("/")
  end

  describe "Competitor" do
    before(:each) do
      @registrant = FactoryGirl.create(:competitor)
      @categories = [] # none are _needed_
    end
    it "renders dates in nice formats" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      rendered.should match(/Jan 10, 2012/)
      rendered.should match(/Feb 11, 2012/)
    end
    it "lists competitor costs" do
      render
      rendered.should match(/100/)
    end
  end

  describe "as non-competitor" do
    before(:each) do
      @registrant = FactoryGirl.create(:noncompetitor)
    end
    it "displays the registration_period for non-competitors" do
      render
      rendered.should match(/50/)
    end
  end
end
