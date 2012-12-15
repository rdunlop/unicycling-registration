require 'spec_helper'

describe "events/index" do
  before(:each) do
    @ev1 = FactoryGirl.create(:event)
    @ev2 = FactoryGirl.create(:event)
    assign(:events, [
           @ev1, @ev2
    ])
    @category = @ev1.category
  end

  it "renders a list of events" do
    render
    assert_select "h2", :text => "Category: " + @category.to_s
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => @ev1.to_s, :count => 1
    assert_select "tr>td", :text => @ev2.to_s, :count => 1
    assert_select "tr>td", :text => 1.to_s, :count => 2 # position
  end
end
