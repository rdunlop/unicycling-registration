require 'spec_helper'

describe EventCopier do
  before do
    FactoryGirl.create(:tenant, subdomain: "other")
    Apartment::Tenant.create "other"
  end
  let(:copier) { described_class.new("other") }

  context "with an event with a single category and choice" do
    before do
      Apartment::Tenant.switch "other" do
        event = FactoryGirl.create(:event)
        FactoryGirl.create(:event_category, event: event)
        FactoryGirl.create(:event_choice, event: event)
      end
    end

    it "initially has no events" do
      expect(Event.count).to eq(0)
    end

    it "can copy the events" do
      copier.copy_events
      expect(Event.count).to eq(1)
    end
  end
end
