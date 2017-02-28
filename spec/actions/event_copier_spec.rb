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
        FactoryGirl.create(:event_choice, event: event)
      end
    end

    before { copier.copy_events }

    it "copies the category" do
      expect(Category.count).to eq(1)
      expect(Category.first.translations.count).to eq(1)
    end

    it "copies the events" do
      expect(Event.count).to eq(1)
    end

    it "copies the event_category" do
      expect(EventCategory.count).to eq(1)
    end

    it "copies the event_choice" do
      expect(EventChoice.count).to eq(1)
    end
  end

  context "with an event with a customized set of event_categories" do
    before do
      Apartment::Tenant.switch "other" do
        event = FactoryGirl.create(:event)
        event.event_categories.first.update(name: "First Category")
        FactoryGirl.create(:event_category, event: event, name: "Second Category")
      end
    end

    it "can copy the event categories" do
      copier.copy_events
      expect(Event.first.event_categories.count).to eq(2)
    end
  end

  context "with an event with a translated event name" do
    before do
      Apartment::Tenant.switch "other" do
        event = FactoryGirl.create(:event)
        event.translations.create(name: "Francais", locale: "fr")
      end
    end

    it "can copy the event name translations" do
      copier.copy_events
      expect(Event.first.translations.count).to eq(2)
    end
  end
end
