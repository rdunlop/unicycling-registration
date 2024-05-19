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
  let(:member) { FactoryBot.build(:member) }

  it "must have a competitor and registrant" do
    member = described_class.new

    expect(member.valid?).to eq(false)

    member.competitor = FactoryBot.create(:event_competitor)

    expect(member.valid?).to eq(false)

    member.registrant = FactoryBot.create(:registrant)

    expect(member.valid?).to eq(true)
  end

  describe "#to_s" do
    it "adds (alternate)" do
      member.alternate = true

      expect(member.to_s).to eq("#{member.registrant}(alternate)")
    end

    it "has normal to_s" do
      expect(member.to_s).to eq(member.registrant.to_s)
    end
  end

  context "when using imported Registrants" do
    before do
      EventConfiguration.singleton.update(imported_registrants: true)
    end

    it "can save a member with an imported_registrant" do
      imported_registrant = FactoryBot.create(:imported_registrant)
      member = FactoryBot.build(:member, registrant: imported_registrant)

      member.save!
    end
  end
end
