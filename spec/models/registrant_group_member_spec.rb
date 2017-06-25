# == Schema Information
#
# Table name: registrant_group_members
#
#  id                      :integer          not null, primary key
#  registrant_id           :integer
#  registrant_group_id     :integer
#  created_at              :datetime
#  updated_at              :datetime
#  additional_details_type :string
#  additional_details_id   :integer
#
# Indexes
#
#  index_registrant_group_members_on_registrant_group_id  (registrant_group_id)
#  index_registrant_group_members_on_registrant_id        (registrant_id)
#  reg_group_reg_group                                    (registrant_id,registrant_group_id) UNIQUE
#

require 'spec_helper'

describe RegistrantGroupMember do
  before(:each) do
    @rgm = FactoryGirl.create(:registrant_group_member)
    @rg = @rgm.registrant_group
  end

  it "has a valid factory" do
    expect(@rgm.valid?).to eq(true)
  end

  it "registrant is required" do
    @rgm.registrant = nil
    expect(@rgm.valid?).to eq(false)
  end

  it "registrant_group is required" do
    @rgm.registrant_group = nil
    expect(@rgm.valid?).to eq(false)
  end

  it "describes itself as the group" do
    expect(@rgm.to_s).to eq(@rgm.registrant.to_s)
  end

  it "cannot have the same member twice in the same group" do
    @rgm2 = FactoryGirl.build(:registrant_group_member, registrant: @rgm.registrant, registrant_group: @rg)
    expect(@rgm2.valid?).to eq(false)
  end
end
