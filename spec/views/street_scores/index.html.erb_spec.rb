require 'spec_helper'

describe "street_scores/index" do
  before(:each) do
    @ss1 = FactoryGirl.create(:score)
    @ss2 = FactoryGirl.create(:score)
    assign(:street_scores, [@ss1, @ss2])
    @ec = FactoryGirl.create(:competition)
    assign(:competition, @ec)

    @judge = FactoryGirl.create(:judge, :competition => @ec)
    assign(:judge, @judge)
    assign(:competitors, [])
    assign(:score, FactoryGirl.build(:score))
  end

  it "renders a list of street_scores" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => @ss1.competitor.name, :count => 1
    assert_select "tr>td", :text => @ss2.competitor.name, :count => 1
    assert_select "tr>td", :text => @ss1.val_1.to_s, :count => 2
  end
end
