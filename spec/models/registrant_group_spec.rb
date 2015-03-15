# == Schema Information
#
# Table name: registrant_groups
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_registrant_groups_registrant_id  (registrant_id)
#

require 'spec_helper'

describe RegistrantGroup do
  before(:each) do
    @rg = FactoryGirl.create(:registrant_group)
  end

  it "has a valid factory" do
    expect(@rg.valid?).to eq(true)
  end

  it "name is optional" do
    @rg.name = nil
    expect(@rg.valid?).to eq(true)
  end

  it "has a contact_person" do
    expect(@rg.contact_person).not_to be_nil
  end

  it "has multiple registrant_group_members" do
    FactoryGirl.create(:registrant_group_member, :registrant_group => @rg)
    FactoryGirl.create(:registrant_group_member, :registrant_group => @rg)
    FactoryGirl.create(:registrant_group_member, :registrant_group => @rg)
    expect(@rg.registrant_group_members.count).to eq(3)
  end

  it "can assign a registrant to the contact_person" do
    @reg = FactoryGirl.create(:noncompetitor)
    @rg.contact_person = @reg
    expect(@rg.contact_person).to eq(@reg)
  end

  it "can be found via the registrant" do
    @rgm = FactoryGirl.create(:registrant_group_member, :registrant_group => @rg)
    @reg = @rgm.registrant
    expect(@reg.registrant_groups).to eq([@rg])
  end
end
