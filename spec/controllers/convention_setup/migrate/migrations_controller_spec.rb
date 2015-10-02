require 'spec_helper'

describe ConventionSetup::Migrate::MigrationsController do
  before do
    FactoryGirl.create(:tenant, subdomain: "other")
    Apartment::Tenant.create "other"
    Apartment::Tenant.switch "other" do
      event = FactoryGirl.create(:event)
      FactoryGirl.create(:event_category, event: event)
      FactoryGirl.create(:event_choice, event: event)
    end
  end

  describe "as an admin user" do
    before do
      user = FactoryGirl.create(:super_admin_user)
      sign_in user
    end

    it "initially has no events" do
      expect(Event.count).to eq(0)
    end

    it "can copy the events" do
      post :create_events, tenant: "other"
      expect(Event.count).to eq(1)
    end
  end

end
