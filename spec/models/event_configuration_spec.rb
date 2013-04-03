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

  it "can have a blank comp_noncomp_url" do
    @ev.comp_noncomp_url = ""
    @ev.valid?.should == true
  end

  it "must have a test_mode" do
    @ev.test_mode = nil
    @ev.valid?.should == false
  end

  it "defaults test_mode to true" do
    ev = EventConfiguration.new
    ev.test_mode.should == true
  end

  it "returns the live paypal url when nothing is configured" do
    ENV['PAYPAL_TEST'] = nil
    EventConfiguration.paypal_base_url.should == "https://www.sandbox.paypal.com"
  end
  it "returns the live paypal url when TEST is false" do
    ENV['PAYPAL_TEST'] = "false"
    EventConfiguration.paypal_base_url.should == "https://www.paypal.com"
  end
  it "returns the test paypal url when TEST is true" do
    ENV['PAYPAL_TEST'] = "true"
    EventConfiguration.paypal_base_url.should == "https://www.sandbox.paypal.com"
  end
end
