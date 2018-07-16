require 'spec_helper'

describe RegistrantTemplateParser do
  describe "searching for template strings" do
    it "finds strings which start with {{" do
      templates = described_class.new(nil, "{{Hello}}").found_templates
      expect(templates).to eq(["Hello"])
    end
  end

  describe "it finds non-matches templates" do
    it "considers Hello to be a non-matched template" do
      subject = described_class.new(nil, "{{Hello}}")
      expect(subject).not_to be_valid
    end

    it "considers ID to be a matched-template" do
      subject = described_class.new(nil, "{{ID}}")
      expect(subject).to be_valid
    end
  end

  describe "replacing templates with contents" do
    let(:registrant) { FactoryBot.create(:registrant) }
    let!(:event_configuration) { FactoryBot.create(:event_configuration) }

    it "Replaces ID with registrant ID" do
      subject = described_class.new(registrant, "Hello {{ID}} How are you?")
      expect(subject.result).to eq("Hello #{registrant.bib_number} How are you?")
    end
  end

  describe "events output" do
    let(:registrant) { FactoryBot.create(:registrant) }
    let!(:event_configuration) { FactoryBot.create(:event_configuration) }
    let!(:event_sign_up) { FactoryBot.create(:registrant_event_sign_up, registrant: registrant) }

    it "lists events with categories for the registrant" do
      expect(described_class.events(registrant)).to include(event_sign_up.event.category.name)
      expect(described_class.events(registrant)).to include("===========")
      expect(described_class.events(registrant)).to include(event_sign_up.event.name)
    end
  end
end
