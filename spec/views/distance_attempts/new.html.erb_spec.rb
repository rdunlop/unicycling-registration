require 'spec_helper'

describe "distance_attempts/new" do
  before(:each) do
    @ec = FactoryGirl.create(:competition)
    assign(:competition, @ec)

    @comp1 = FactoryGirl.create(:event_competitor, :competition => @ec)
    @comp2 = FactoryGirl.create(:event_competitor, :competition => @ec)
    @judge = FactoryGirl.create(:judge, :competition => @ec)

    @da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp1)

    assign(:distance_attempts, [@da1])
  end

  it "renders a list of distance_attempts" do
    render
    assert_select "tr:nth-child(1)" do |row|
      assert_select "td", :text => @da1.distance.to_s, :count => 1
      assert_select "td", :text => "no", :count => 1
    end
  end
  it "renders the registrant details" do
    assign(:competitor, @comp1)
    assign(:distance_attempt, DistanceAttempt.new)

    render

    assert_select "span", :text => "Name: " + @comp1.name
  end
  it "create a form that allows creating new entries" do
    assign(:competitor, @comp1)
    assign(:distance_attempt, DistanceAttempt.new)

    render

    assert_select "form", :action => judge_distance_attempts_path(@judge, @comp1), :method => "post" do
        assert_select "input#distance_attempt_distance", :name => "distance_attempt[distance]"
        assert_select "input#distance_attempt_fault", :name => "distance_attempt[fault]"
    end
  end
end
