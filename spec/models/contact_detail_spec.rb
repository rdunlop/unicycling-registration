# == Schema Information
#
# Table name: contact_details
#
#  id                      :integer          not null, primary key
#  registrant_id           :integer
#  address                 :string(255)
#  city                    :string(255)
#  state                   :string(255)
#  zip                     :string(255)
#  country_residence       :string(255)
#  country_representing    :string(255)
#  phone                   :string(255)
#  mobile                  :string(255)
#  email                   :string(255)
#  club                    :string(255)
#  club_contact            :string(255)
#  usa_member_number       :string(255)
#  emergency_name          :string(255)
#  emergency_relationship  :string(255)
#  emergency_attending     :boolean
#  emergency_primary_phone :string(255)
#  emergency_other_phone   :string(255)
#  responsible_adult_name  :string(255)
#  responsible_adult_phone :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

require 'spec_helper'

describe ContactDetail do
  before(:each) do
    FactoryGirl.create(:event_configuration, :with_usa)
    @reg = FactoryGirl.build_stubbed(:registrant)
    @cd = FactoryGirl.build_stubbed(:contact_detail, :registrant => @reg)
    allow(@reg).to receive(:age).and_return(20)
  end

  it "has a valid from FactoryGirl" do
    @cd.valid?.should == true
  end

  it "requires address" do
    @cd.address = nil
    @cd.valid?.should == false
  end

  it "requires city" do
    @cd.city = nil
    @cd.valid?.should == false
  end

  it "requires state" do
    @cd.state = nil
    @cd.valid?.should == false
  end

  it "requires zip" do
    @cd.zip = nil
    @cd.valid?.should == false
  end

  it "requires country_residence" do
    @cd.country_residence = nil
    @cd.valid?.should == false
  end

  it "returns the country of residence as the country" do
    @cd.country_residence = "CA"
    @cd.country_code.should == "CA"
  end

  it "returns the country_representing, when specified" do
    @cd.country_residence = "US"
    @cd.country_representing = "CA"
    @cd.country_code.should == "CA"
  end

  it "returns the country of residence even when country representing is blank" do
    @cd.country_residence = "CA"
    @cd.country_representing = ""
    @cd.country_code.should == "CA"
  end

  it "requires emergency_contact name" do
    @cd.emergency_name = nil
    @cd.valid?.should == false
  end

  it "requires emergency_contact relationship" do
    @cd.emergency_relationship = nil
    @cd.valid?.should == false
  end

  it "requires emergency_contact primary_phone" do
    @cd.emergency_primary_phone = nil
    @cd.valid?.should == false
  end
end
