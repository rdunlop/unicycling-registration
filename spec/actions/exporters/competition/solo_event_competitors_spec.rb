require 'spec_helper'

describe Exporters::Competition::SoloEventCompetitors do
  describe "#headers" do
    let!(:competition) { FactoryBot.create(:competition) }
    let(:headers) { described_class.new(competition).headers }
    let(:expected_headers) do
      ["ID", "LastName", "FirstName", "Country", "Gender", "Age Group"]
    end

    it "describes the competitors headers" do
      expect(headers).to eq(expected_headers)
    end
  end

  describe "#rows" do
    let!(:age_group_type) { FactoryBot.create(:age_group_type) }
    let!(:age_group_entry) do
      FactoryBot.create(:age_group_entry,
                        age_group_type: age_group_type,
                        start_age: 18,
                        end_age: 100,
                        gender: "Male",
                        short_description: "Senior Male")
    end
    let!(:competition) { FactoryBot.create(:competition, age_group_type: age_group_type) }
    let!(:registrant) { FactoryBot.create(:competitor, birthday: Date.new(1998, 4, 20), gender: "Male") }
    let!(:competitor) { Competitor.create!(competition: competition) }
    let!(:member) { FactoryBot.create(:member, competitor: competitor, registrant: registrant) }

    let(:rows) { described_class.new(competition).rows }

    let(:expected_row) do
      [
        registrant.bib_number,
        registrant.last_name,
        registrant.first_name,
        registrant.country,
        registrant.gender,
        "Senior Male"
      ]
    end

    it "includes the base information" do
      expect(rows.first).to eq(expected_row)
    end
  end
end
