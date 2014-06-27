require 'spec_helper'

describe "distance_attempts/index" do
  before(:each) do
    @ec = FactoryGirl.create(:competition)
    assign(:competition, @ec)

    @comp1 = FactoryGirl.create(:event_competitor, :competition => @ec)
    @comp2 = FactoryGirl.create(:event_competitor, :competition => @ec)
    @judge = FactoryGirl.create(:judge)

    @da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp1)

    assign(:distance_attempt, DistanceAttempt.new)
    assign(:recent_distance_attempts, [])
    assign(:max_distance_attempts, [@da1])
  end

  it "renders a form for searching for a competitor" do
    render
    assert_select "form", :action => judge_distance_attempts_path(@judge), :method => "get" do
        assert_select "input#distance_attempt_distance", :name => "distance_attempt_distance"
    end
  end
end
