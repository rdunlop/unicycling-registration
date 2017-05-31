# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

require 'spec_helper'

describe RegistrantGroupType do
  before(:each) do
    @rgt = FactoryGirl.create(:registrant_group_type)
  end

  it "has a valid factory" do
    expect(@rgt).to be_valid
  end

  it "notes are optional" do
    @rgt.notes = nil
    expect(@rgt).to be_valid
  end

  it "has a source_element" do
    expect(@rgt.source_element).not_to be_nil
  end

  it "has multiple registrant_groups" do
    FactoryGirl.create(:registrant_group, registrant_group_type: @rgt)
    FactoryGirl.create(:registrant_group, registrant_group_type: @rgt)
    FactoryGirl.create(:registrant_group, registrant_group_type: @rgt)
    expect(@rgt.registrant_groups.count).to eq(3)
  end
end
