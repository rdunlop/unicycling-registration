require 'spec_helper'

describe ConventionSeriesMember do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:series) { FactoryBot.create(:convention_series) }

  it "must have a series and tenant" do
    member = described_class.new
    expect(member.valid?).to eq(false)
    member.convention_series = series
    member.tenant = tenant
    expect(member.valid?).to eq(true)
  end
end

# == Schema Information
#
# Table name: public.convention_series_members
#
#  id                   :integer          not null, primary key
#  convention_series_id :integer          not null
#  tenant_id            :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  convention_series_member_ids_unique                      (tenant_id,convention_series_id) UNIQUE
#  index_convention_series_members_on_convention_series_id  (convention_series_id)
#  index_convention_series_members_on_tenant_id             (tenant_id)
#
