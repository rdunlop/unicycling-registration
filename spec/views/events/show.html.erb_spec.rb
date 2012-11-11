require 'spec_helper'

describe "events/show" do
  before(:each) do
    @event = FactoryGirl.create(:event)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name of Event/)
    rendered.should match(/#{@event.category.name}/)
    rendered.should match(/Some Description/)
    rendered.should match(/1/)
  end
end
