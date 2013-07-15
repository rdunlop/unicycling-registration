require 'spec_helper'

describe "distance_attempts/index" do
  before(:each) do
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
    assign(:event_category, @ec)

    @comp1 = FactoryGirl.create(:event_competitor, :event_category => @ec)
    @comp2 = FactoryGirl.create(:event_competitor, :event_category => @ec)
    @judge = FactoryGirl.create(:judge)

    @da1 = FactoryGirl.create(:distance_attempt, :competitor => @comp1)

    assign(:max_distance_attempts, [@da1])
  end

  it "renders a form for searching for a competitor" do
    render
    assert_select "form", :action => judge_distance_attempts_path(@judge), :method => "get" do
        assert_select "input#external_id", :name => "external_id"
    end
  end
end
