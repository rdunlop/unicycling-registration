# == Schema Information
#
# Table name: contact_details
#
#  id                                         :integer          not null, primary key
#  registrant_id                              :integer
#  address                                    :string(255)
#  city                                       :string(255)
#  state_code                                 :string(255)
#  zip                                        :string(255)
#  country_residence                          :string(255)
#  country_representing                       :string(255)
#  phone                                      :string(255)
#  mobile                                     :string(255)
#  email                                      :string(255)
#  club                                       :string(255)
#  club_contact                               :string(255)
#  organization_member_number                 :string(255)
#  emergency_name                             :string(255)
#  emergency_relationship                     :string(255)
#  emergency_attending                        :boolean          default(FALSE), not null
#  emergency_primary_phone                    :string(255)
#  emergency_other_phone                      :string(255)
#  responsible_adult_name                     :string(255)
#  responsible_adult_phone                    :string(255)
#  created_at                                 :datetime
#  updated_at                                 :datetime
#  organization_membership_manually_confirmed :boolean          default(FALSE), not null
#  birthplace                                 :string(255)
#  italian_fiscal_code                        :string(255)
#  organization_membership_system_confirmed   :boolean          default(FALSE), not null
#  organization_membership_system_status      :string
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
  subject(:contact_detail) { @cd }

  it "has a valid from FactoryGirl" do
    expect(@cd.valid?).to eq(true)
  end

  context "when italian_requirements is enabled" do
    before do
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

  context "with a db-backed contact_detail" do
    let(:contact_detail) { FactoryGirl.create(:contact_detail) }

    context "when organization_membership_config mode is enabled" do
      before do
        EventConfiguration.singleton.update_attribute(:organization_membership_type, "usa")
      end

      it "calls the update worker" do
        expect(contact_detail).to receive(:update_usa_membership_status)
        contact_detail.save
      end
    end
    context "when organization_membership_config mode is not enabled" do
      before do
        EventConfiguration.singleton.update_attribute(:organization_membership_type, nil)
      end
      it "does not call the update worker" do
        expect(contact_detail).not_to receive(:update_usa_membership_status)
        contact_detail.save
      end
    end
  end

  context "without a country_residence or country_representing" do
    before { contact_detail.country_residence = nil }

    it "returns the country of N/A" do
      expect(subject.country).to eq("N/A")
    end

    it "returns nil for state" do
      subject.state_code = nil
      expect(subject.state).to be_nil
    end
  end

  context "without a state_code" do
    before { contact_detail.state_code = nil }

    it "returns a state of nil" do
      expect(subject.state).to be_nil
    end
  end

  context "when the address fields are not required" do
    before do
      EventConfiguration.singleton.update_attribute(:request_address, false)
    end

    it { is_expected.to_not validate_presence_of(:address) }
    it { is_expected.to_not validate_presence_of(:city) }
    it { is_expected.to_not validate_presence_of(:state_code) }
    it { is_expected.to_not validate_presence_of(:zip) }
    it { is_expected.to_not validate_presence_of(:country_residence) }
  end

  context "when address fields are required" do
    # This is the default for EventConfiguration

    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state_code) }
    it { is_expected.to validate_presence_of(:zip) }
    it { is_expected.to validate_presence_of(:country_residence) }

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
  end

  context "when emergency fields are not required" do
    before do
      EventConfiguration.singleton.update_attribute(:request_emergency_contact, false)
    end

    it { is_expected.not_to validate_presence_of(:emergency_name) }
    it { is_expected.not_to validate_presence_of(:emergency_relationship) }
    it { is_expected.not_to validate_presence_of(:emergency_primary_phone) }
  end

  it { is_expected.to validate_presence_of(:emergency_name) }
  it { is_expected.to validate_presence_of(:emergency_relationship) }
  it { is_expected.to validate_presence_of(:emergency_primary_phone) }

  context "for a minor" do
    before { allow(@reg).to receive(:age).and_return(12) }

    context "when responsible_adult is not required" do
      before do
        EventConfiguration.singleton.update_attribute(:request_responsible_adult, false)
      end

      it { is_expected.not_to validate_presence_of(:responsible_adult_name) }
      it { is_expected.not_to validate_presence_of(:responsible_adult_phone) }
    end

    context "when responsible_adult fields are required" do
      it { is_expected.to validate_presence_of(:responsible_adult_name) }
      it { is_expected.to validate_presence_of(:responsible_adult_phone) }
    end
  end
end
