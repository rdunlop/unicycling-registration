require 'spec_helper'

describe "street_scores/index" do
  before(:each) do
    @ss1 = FactoryGirl.create(:street_score)
    @ss2 = FactoryGirl.create(:street_score)
    assign(:street_scores, [@ss1, @ss2])
    @ev = FactoryGirl.create(:event)
    @ec = @ev.event_categories.first
    assign(:event_category, @ec)

    @judge = FactoryGirl.create(:judge, :event_category => @ec)
    assign(:judge, @judge)
    assign(:competitors, [])
    assign(:score, FactoryGirl.build(:street_score))
  end

  it "renders a list of street_scores" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => @ss1.competitor.name, :count => 1
    assert_select "tr>td", :text => @ss2.competitor.name, :count => 1
    assert_select "tr>td", :text => @ss1.val_1.to_s, :count => 2
  end
end
