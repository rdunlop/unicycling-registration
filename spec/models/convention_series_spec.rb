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

  describe "#registrant_data" do
    before do
      Apartment::Tenant.create("new_tenant")
    end
    let!(:member) { FactoryGirl.create(:convention_series_member, convention_series: series, tenant: tenant) }
    let!(:member2) { FactoryGirl.create(:convention_series_member, convention_series: series, tenant: Tenant.find_by(subdomain: Apartment::Tenant.current)) }

    context "with a few registrants" do
      let!(:reg1) { FactoryGirl.create(:competitor, first_name: "Bob", last_name: "Smith", bib_number: 1) }
      let!(:reg2) { FactoryGirl.create(:competitor, first_name: "James", last_name: "Gordon", bib_number: 2) }

      it "shows registrants across all subdomains" do
        result = series.registrant_data
        expect(result).to match(
          ids: [1, 2],
          subdomains: {
            "new_tenant" => {},
            Apartment::Tenant.current => {
              1 => "Bob Smith",
              2 => "James Gordon"
            }
          }
        )
      end
    end
  end
end
