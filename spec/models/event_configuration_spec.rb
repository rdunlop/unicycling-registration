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

  it "should be open if no periods are defined" do
    EventConfiguration.closed?.should == false
  end

  describe "with a registration period" do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period, :start_date => Date.new(2012, 11,03), :end_date => Date.new(2012,11,07))
    end
    it "should be open on the last day of registration" do
      EventConfiguration.closed?(Date.new(2012,11,07)).should == false
    end
    it "should be open as long as the registration_period is current" do
      d = Date.new(2012,11,07)
      @rp.current_period?(d).should == true
      EventConfiguration.closed?(d).should == false

      e = Date.new(2012,11,8)
      @rp.current_period?(e).should == true
      EventConfiguration.closed?(e).should == false

      f = Date.new(2012,11,9)
      @rp.current_period?(f).should == false
      EventConfiguration.closed?(f).should == true
    end
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
