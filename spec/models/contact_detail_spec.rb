# == Schema Information
#
# Table name: contact_details
#
#  id                              :integer          not null, primary key
#  registrant_id                   :integer
#  address                         :string(255)
#  city                            :string(255)
#  state_code                      :string(255)
#  zip                             :string(255)
#  country_residence               :string(255)
#  country_representing            :string(255)
#  phone                           :string(255)
#  mobile                          :string(255)
#  email                           :string(255)
#  club                            :string(255)
#  club_contact                    :string(255)
#  usa_member_number               :string(255)
#  emergency_name                  :string(255)
#  emergency_relationship          :string(255)
#  emergency_attending             :boolean          default(FALSE), not null
#  emergency_primary_phone         :string(255)
#  emergency_other_phone           :string(255)
#  responsible_adult_name          :string(255)
#  responsible_adult_phone         :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  usa_confirmed_paid              :boolean          default(FALSE), not null
#  usa_family_membership_holder_id :integer
#  birthplace                      :string
#  italian_fiscal_code             :string
#
# Indexes
#
#  index_contact_details_on_registrant_id  (registrant_id) UNIQUE
#  index_contact_details_registrant_id     (registrant_id)
#

require 'spec_helper'

describe ContactDetail do
  before(:each) do
    FactoryGirl.create(:event_configuration, :with_usa)
    @reg = FactoryGirl.build_stubbed(:registrant)
    @cd = FactoryGirl.build_stubbed(:contact_detail, registrant: @reg)
    allow(@reg).to receive(:age).and_return(20)
  end

  it "has a valid from FactoryGirl" do
    expect(@cd.valid?).to eq(true)
  end

  it "requires address" do
    @cd.address = nil
    expect(@cd.valid?).to eq(false)
  end

  context "when italian_requirements is enabled" do
    before :each do
      EventConfiguration.singleton.update_attribute(:italian_requirements, true)
    end

    it "requires vat_number if from italy" do
      @cd.country_residence = "IT"
      @cd.birthplace = "Place"
      @cd.italian_fiscal_code = nil
      expect(@cd).to be_invalid
      @cd.italian_fiscal_code = "CCCCCC99C99C999C"
      expect(@cd).to be_valid
    end

    it "requires birthplace" do
      @cd.country_residence = "CA"
      @cd.birthplace = nil
      expect(@cd).to be_invalid
      @cd.birthplace = "Canada"
      expect(@cd).to be_valid
    end

    it "doesn't require vat_number if from canada" do
      @cd.country_residence = "CA"
      @cd.birthplace = "Canada"
      @cd.italian_fiscal_code = nil
      expect(@cd).to be_valid
      @cd.italian_fiscal_code = "CCCCCC99C99C999C"
      expect(@cd).to be_valid
    end
  end

  it "requires city" do
    @cd.city = nil
    expect(@cd.valid?).to eq(false)
  end

  it "requires state" do
    @cd.state_code = nil
    expect(@cd.valid?).to eq(false)
  end

  it "requires zip" do
    @cd.zip = nil
    expect(@cd.valid?).to eq(false)
  end

  it "requires country_residence" do
    @cd.country_residence = nil
    expect(@cd.valid?).to eq(false)
  end

  it "returns the country of residence as the country" do
    @cd.country_residence = "CA"
    expect(@cd.country_code).to eq("CA")
  end

  it "returns the country_representing, when specified" do
    @cd.country_residence = "US"
    @cd.country_representing = "CA"
    expect(@cd.country_code).to eq("CA")
  end

  it "returns the country of residence even when country representing is blank" do
    @cd.country_residence = "CA"
    @cd.country_representing = ""
    expect(@cd.country_code).to eq("CA")
  end

  it "requires emergency_contact name" do
    @cd.emergency_name = nil
    expect(@cd.valid?).to eq(false)
  end

  it "requires emergency_contact relationship" do
    @cd.emergency_relationship = nil
    expect(@cd.valid?).to eq(false)
  end

  it "requires emergency_contact primary_phone" do
    @cd.emergency_primary_phone = nil
    expect(@cd.valid?).to eq(false)
  end
end
