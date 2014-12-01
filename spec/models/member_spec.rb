# == Schema Information
#
# Table name: members
#
#  id                        :integer          not null, primary key
#  competitor_id             :integer
#  registrant_id             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  dropped_from_registration :boolean          default(FALSE)
#
# Indexes
#
#  index_members_competitor_id  (competitor_id)
#  index_members_registrant_id  (registrant_id)
#

require 'spec_helper'

describe Member do
  it "must have a competitor and registrant" do
    member = Member.new

    member.valid?.should == false

    member.competitor = FactoryGirl.create(:event_competitor)

    member.valid?.should == false

    member.registrant = FactoryGirl.create(:registrant)

    member.valid?.should == true
  end
end
