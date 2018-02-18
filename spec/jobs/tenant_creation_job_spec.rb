require "spec_helper"

RSpec.describe TenantCreationJob do
  let(:tenant) { FactoryBot.create(:tenant, subdomain: "new_tenant") }

  describe "#perform" do
    subject(:job) { described_class.new(tenant.id) }

    it "creates a new tenant" do
      job.perform_now
      Apartment::Tenant.switch!("new_tenant")
    end
  end
end
