require 'spec_helper'

describe BibNumberFinder::RegistrantMatch do
  let(:subject) { described_class.new(new_registrant, user) }
  let(:birthday) { Date.new(2000, 1, 10) }
  let(:user) { FactoryBot.create(:user) }
  let(:new_registrant) { FactoryBot.build(:competitor, first_name: "Bob", last_name: "Smith", birthday: birthday) }

  context "when no other conventions in this series" do
    it "returns no match" do
      expect(subject.matching_registrant).to be_nil
    end
  end

  context "with a matching registrant in another tenant" do
    let(:tenant) { Tenant.first }
    let!(:series) { FactoryBot.create(:convention_series) }
    let!(:series_member) { FactoryBot.create(:convention_series_member, convention_series: series, tenant: tenant) }

    let!(:other_tenant) { FactoryBot.create(:tenant, subdomain: "other") }
    before do
      Apartment::Tenant.create "other"
      Apartment::Tenant.switch "other" do
        FactoryBot.create(:competitor, user: user, first_name: "Bob", last_name: "Smith", birthday: birthday, bib_number: 123)
      end
    end

    let!(:series_member2) { FactoryBot.create(:convention_series_member, convention_series: series, tenant: other_tenant) }

    it "returns the bib number of the matching tenant" do
      expect(subject.matching_registrant).to eq(123)
    end
  end
end
