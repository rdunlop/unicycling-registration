# == Schema Information
#
# Table name: registrant_group_members
#
#  id                  :integer          not null, primary key
#  registrant_id       :integer
#  registrant_group_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'spec_helper'

describe RegistrantGroupMember do
  before(:each) do
    @rgm= FactoryGirl.create(:registrant_group_member)
    @rg = @rgm.registrant_group
  end

  it "has a valid factory" do
    @rgm.valid?.should == true
  end

  it "registrant is required" do
    @rgm.registrant = nil
    @rgm.valid?.should == false
  end

  it "registrant_group is required" do
    @rgm.registrant_group = nil
    @rgm.valid?.should == false
  end

  it "describes itself as the group" do
    @rgm.to_s.should == @rg.name
  end

  it "cannot have the same member twice in the same group" do
    @rgm2 = FactoryGirl.build(:registrant_group_member, :registrant => @rgm.registrant, :registrant_group => @rg)
    @rgm2.valid?.should == false
  end
end
