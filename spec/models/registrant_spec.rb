require 'spec_helper'

describe Registrant do
  before(:each) do
    @reg = FactoryGirl.create(:registrant)
  end

  it "has a valid reg from FactoryGirl" do
    @reg.valid?.should == true
  end

  it "requires a birthday" do
    @reg.birthday = nil
    @reg.valid?.should == false
  end

  it "requires first name" do
    @reg.first_name = nil
    @reg.valid?.should == false
  end

  it "requires last name" do
    @reg.last_name = nil
    @reg.valid?.should == false
  end

  it "requires gender" do
    @reg.gender = nil
    @reg.valid?.should == false
  end

  it "requires country" do
    @reg.gender = nil
    @reg.valid?.should == false
  end
  it "requires city" do
    @reg.city = nil
    @reg.valid?.should == false
  end
  it "has either Male or Female gender" do
    @reg.gender = "Male"
    @reg.valid?.should == true

    @reg.gender = "Female"
    @reg.valid?.should == true

    @reg.gender = "Other"
    @reg.valid?.should == false
  end

  it "has event_choices" do
    @ec = FactoryGirl.create(:registrant_choice, :registrant => @reg)
    @reg.registrant_choices.should == [@ec]
  end

  describe "shortcut for event_choices" do
    it "returns 0 if the given choice doesn't exist" do
      ec = FactoryGirl.create(:event_choice)
      @reg.chose(ec).should == false
    end
    it "returns 1 if the given choice was made" do
      ec = FactoryGirl.create(:event_choice)
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => ec, :value => "1")
      @reg.chose(ec).should == true
    end
    it "returns 0 if the given choice was made to be 0" do
      ec = FactoryGirl.create(:event_choice)
      rc = FactoryGirl.create(:registrant_choice, :registrant => @reg, :event_choice => ec, :value => "0")
      @reg.chose(ec).should == false
    end
  end
end
