require 'spec_helper'

describe RepresentationType do
  let(:object) { double(state: "Illinois", country: "USA", club: "Chi-club") }
  let(:subject) { described_class.new(object) }
  let(:result) { subject.to_s }

  context "with a state-configuration" do
    before do
      ec = EventConfiguration.singleton
      ec.update(representation_type: "state")
    end

    it "displays state" do
      expect(result).to eq("Illinois")
    end

    it "displays the description" do
      expect(described_class.description).to eq("State")
    end
  end

  context "with a country-configuration" do
    before do
      ec = EventConfiguration.singleton
      ec.update(representation_type: "country")
    end

    it "displays country" do
      expect(result).to eq("USA")
    end

    it "displays the description" do
      expect(described_class.description).to eq("Country")
    end
  end

  context "with a club-configuration" do
    before do
      ec = EventConfiguration.singleton
      ec.update(representation_type: "club")
    end

    it "displays club" do
      expect(result).to eq("Chi-club")
    end

    it "displays the description" do
      expect(described_class.description).to eq("Club")
    end
  end
end
