require 'spec_helper'

describe Event do
  before(:each) do
    @ev = FactoryGirl.create(:event)
  end
  it "is valid from FactoryGirl" do
    @ev.valid?.should == true
  end
  it "requires a name" do
    @ev.name = nil
    @ev.valid?.should == false
  end

  it "requires a category" do
    @ev.category = nil
    @ev.valid?.should == false
  end

  it "should have name as to_s" do
    @ev.to_s.should == @ev.name
  end


  it "has many even_choices" do
    @ec = FactoryGirl.create(:event_choice, :event => @ev)
    @ev.event_choices = [@ec]
  end

  it "sorts event choices by position" do
    @ec3 = FactoryGirl.create(:event_choice, :event => @ev, :position => 3)
    @ec1 = FactoryGirl.create(:event_choice, :event => @ev, :position => 1)
    @ec2 = FactoryGirl.create(:event_choice, :event => @ev, :position => 2)

    @ev.event_choices = [@ec1, @ec2, @ec3]
  end
end
