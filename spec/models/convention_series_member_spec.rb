require 'spec_helper'

describe ConventionSeriesMember do
  let(:tenant) { FactoryGirl.create(:tenant) }
  let(:series) { FactoryGirl.create(:convention_series) }

  it "must have a series and tenant" do
    member = described_class.new
    expect(member.valid?).to eq(false)
    member.convention_series = series
    member.tenant = tenant
    expect(member.valid?).to eq(true)
  end
end
