require 'spec_helper'

describe "welcome/judging_menu" do
  before(:each) do
    @judges = [FactoryGirl.create(:judge)]
    @comp = FactoryGirl.create(:competition, :name => "100m", :scoring_class => "Distance")

    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
    controller.stub(:current_user) { FactoryGirl.create(:user) }
    @ability.can :create, LaneAssignment
  end

  it "renders the judges page" do
    render

    assert_select "h1", :text => "My Judging Events"
  end
end
