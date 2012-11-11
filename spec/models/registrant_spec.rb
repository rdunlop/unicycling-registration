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
end
