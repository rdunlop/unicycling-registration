require 'spec_helper'

describe "attending/new.html.erb" do
  before(:each) do
    @registrant = FactoryGirl.create(:registrant)

    @ev1 = FactoryGirl.create(:event)
    @ev2 = FactoryGirl.create(:event)
    @events = [@ev1, @ev2]

    @ec1 = FactoryGirl.create(:event_choice, :event => @ev1)
    @ec2 = FactoryGirl.create(:event_choice, :event => @ev2)
  end

  it "should have the" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => attending_index_path(@registrant), :method => "post" do
      assert_select "input#event_choices_#{@ec1.id}", :name => "event_choices[#{@ec1.id}]"
    end
  end
end
