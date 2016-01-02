# == Schema Information
#
# Table name: members
#
#  id                        :integer          not null, primary key
#  competitor_id             :integer
#  registrant_id             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  dropped_from_registration :boolean          default(FALSE), not null
#  alternate                 :boolean          default(FALSE), not null
#
# Indexes
#
#  index_members_competitor_id  (competitor_id)
#  index_members_registrant_id  (registrant_id)
#

require 'spec_helper'

describe Member do
  let(:member) { FactoryGirl.build(:member) }

  it "must have a competitor and registrant" do
    member = Member.new

    expect(member.valid?).to eq(false)

    member.competitor = FactoryGirl.create(:event_competitor)

    expect(member.valid?).to eq(false)

    member.registrant = FactoryGirl.create(:registrant)

    expect(member.valid?).to eq(true)
  end

  describe "#to_s" do
    it "adds (alternate)" do
      member.alternate = true

      expect(member.to_s).to eq(member.registrant.to_s + "(alternate)")
    end

    it "has normal to_s" do
      expect(member.to_s).to eq(member.registrant.to_s)
    end
  end
end
