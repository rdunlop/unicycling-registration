require 'spec_helper'

describe ConventionSeries do
  it "must have a name" do
    series = described_class.new
    expect(series.valid?).to eq(false)
    series.name = "Muni Championship"
    expect(series.valid?).to eq(true)
  end

  let(:series) { FactoryGirl.create(:convention_series) }
  let!(:tenant) { FactoryGirl.create(:tenant, subdomain: "new_tenant") }

  describe "#add" do
    it "can create a new member" do
      expect do
        series.add("new_tenant")
      end.to change(ConventionSeriesMember, :count).by(1)
    end
  end

  describe "remove" do
    let!(:member) { FactoryGirl.create(:convention_series_member, convention_series: series, tenant: tenant) }

    it "can remove a member" do
      expect do
        series.remove("new_tenant")
      end.to change(ConventionSeriesMember, :count).by(-1)
    end
  end
end
