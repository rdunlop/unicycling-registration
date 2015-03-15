# == Schema Information
#
# Table name: additional_registrant_accesses
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  registrant_id      :integer
#  declined           :boolean
#  accepted_readonly  :boolean
#  created_at         :datetime
#  updated_at         :datetime
#  accepted_readwrite :boolean          default(FALSE)
#
# Indexes
#
#  ada_reg_user                                        (registrant_id,user_id) UNIQUE
#  index_additional_registrant_accesses_registrant_id  (registrant_id)
#  index_additional_registrant_accesses_user_id        (user_id)
#

require 'spec_helper'

describe AdditionalRegistrantAccess do
  before(:each) do
    @ara = FactoryGirl.create(:additional_registrant_access)
  end
  it "can be created from factorygirl" do
    expect(@ara.valid?).to eq(true)
  end
  it "must have a registrant" do
    @ara.registrant = nil
    expect(@ara.valid?).to eq(false)
  end

  it "must have a user" do
    @ara.user = nil
    expect(@ara.valid?).to eq(false)
  end

  it "is declined:false by default" do
    ara = AdditionalRegistrantAccess.new
    expect(ara.declined).to eq(false)
  end

  it "is accepted_readonly:false by default" do
    ara = AdditionalRegistrantAccess.new
    expect(ara.accepted_readonly).to eq(false)
  end

  it "Cannot have a duplicate request" do
    ara2 = FactoryGirl.build(:additional_registrant_access, :user => @ara.user, :registrant => @ara.registrant)
    expect(ara2.valid?).to eq(false)
  end

  describe "when neither declined nor accepeted" do
    before(:each) do
      @ara.declined = false
      @ara.accepted_readonly = false
    end
    it "has a new status" do
      expect(@ara.status).to eq("New")
    end
  end
  describe "when it is accepted" do
    before(:each) do
      @ara.accepted_readonly = true
    end
    it "has an Accepted status" do
      expect(@ara.status).to eq("Accepted")
    end
  end
  describe "when it is declined" do
    before(:each) do
      @ara.declined = true
    end
    it "has a Declined status" do
      expect(@ara.status).to eq("Declined")
    end
    it "even when also accepted" do
      @ara.accepted_readonly = true
      expect(@ara.status).to eq("Declined")
    end
  end
end
