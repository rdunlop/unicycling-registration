require 'spec_helper'

describe EventConfiguration do
  before(:each) do
    @ev = FactoryGirl.build(:event_configuration)
  end

  it "is valid from factoryGirl" do
    @ev.valid?.should == true
  end

  it "has a short name" do
    @ev.short_name = nil
    @ev.valid?.should == false
  end

  it "has a long name" do
    @ev.long_name = nil
    @ev.valid?.should == false
  end

  it "event_url can be nil" do
    @ev.event_url = nil
    @ev.valid?.should == true
  end

  it "event_url must be url" do
    @ev.event_url = "hello"
    @ev.valid?.should == false

    @ev.event_url = "http://www.google.com"
    @ev.valid?.should == true
  end
end
