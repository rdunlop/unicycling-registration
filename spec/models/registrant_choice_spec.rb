require 'spec_helper'

describe RegistrantChoice do
  before(:each) do
    @rc = FactoryGirl.create(:registrant_choice)
  end
  it "is valid from FactoryGirl" do
    @rc.valid?.should == true
  end
  it "requires an event_choice" do
    @rc.event_choice = nil
    @rc.valid?.should == false
  end

  it "requires a registrant" do
    @rc.registrant = nil
    @rc.valid?.should == false
  end

  it "determines if it has a value" do
    @rc.has_value?.should == false
  end
  describe "when a boolean has a value 1" do
    before(:each) do
      @rc.value = "1"
      @rc.save
    end
    it "has_value" do
      @rc.has_value?.should == true
    end
  end
  describe "when a multiple input has a value" do
    before(:each) do
      @ec = @rc.event_choice
      @ec.cell_type = "multiple"
      @ec.multiple_values = "hello,goodbye"
      @ec.save!
    end
    it "has_value with a selection" do
      @rc.value = "hello"
      @rc.save!
      @rc.has_value?.should == true
    end
    it "has no value when blank" do
      @rc.value = ""
      @rc.save!
      @rc.has_value?.should == false
    end
  end
  describe "when a category input has a value" do
    before(:each) do
      @ec = @rc.event_choice
      @ec.cell_type = "category"
      # didn't initialize the event_categories
      @ec.save!
    end
    it "has_value with a selection" do
      @rc.value = "hello"
      @rc.save!
      @rc.has_value?.should == true
    end
    it "has no value when blank" do
      @rc.value = ""
      @rc.save!
      @rc.has_value?.should == false
    end
  end

  describe "when a text input has a value" do
    before(:each) do
      @ec = @rc.event_choice
      @ec.cell_type = "text"
      @ec.save!
    end
    it "has_value with anything" do
      @rc.value = "hi"
      @rc.has_value?.should == true
    end
    it "has no value with blank" do
      @rc.value = ""
      @rc.has_value?.should == false
    end
  end
end
