require 'spec_helper'

describe Exporters::Competition::Simple do
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

  describe "#rows for solo event" do
    let!(:age_group_type) { FactoryBot.create(:age_group_type) }
    let!(:age_group_entry) do
      FactoryBot.create(:age_group_entry,
                        age_group_type: age_group_type,
                        start_age: 18,
                        end_age: 100,
                        gender: "Male",
                        short_description: "Senior Male")
    end
    let!(:competition) { FactoryBot.create(:competition, age_group_type: age_group_type, num_members_per_competitor: "One") }
    let!(:registrant) { FactoryBot.create(:registrant, bib_number: 1, first_name: "Jon", last_name: "Doe", birthday: Date.new(1998, 4, 20), gender: "Male") }
    let!(:competitor) { Competitor.create!(competition: competition) }
    let!(:member) { FactoryBot.create(:member, competitor: competitor, registrant: registrant) }

    let(:rows) { described_class.new(competition).rows }

    let(:expected_row) do
      [
        "1",
        "Doe",
        "Jon",
        "United States",
        "Male",
        "Senior Male"
      ]
    end

    it "includes the base information" do
      expect(rows.first).to eq(expected_row)
    end
  end

  describe "#rows for team event" do
    let!(:age_group_type) { FactoryBot.create(:age_group_type) }
    let!(:age_group_entry) do
      FactoryBot.create(:age_group_entry,
                        age_group_type: age_group_type,
                        start_age: 18,
                        end_age: 100,
                        gender: "Mixed",
                        short_description: "Senior")
    end
    let!(:competition) { FactoryBot.create(:competition, age_group_type: age_group_type, num_members_per_competitor: "Three or more") }
    let!(:registrant1) { FactoryBot.create(:registrant, bib_number: 1, first_name: "Jon", last_name: "Doe", birthday: Date.new(1998, 4, 20), gender: "Male") }
    let!(:registrant2) { FactoryBot.create(:registrant, bib_number: 2, first_name: "Jane", last_name: "Do", birthday: Date.new(1998, 4, 20), gender: "Female") }
    let!(:registrant3) { FactoryBot.create(:registrant, bib_number: 3, first_name: "Juan", last_name: "Dos", birthday: Date.new(1998, 4, 20), gender: "Male") }
    let!(:member1) { FactoryBot.create(:member, registrant: registrant1) }
    let!(:member2) { FactoryBot.create(:member, registrant: registrant2) }
    let!(:member3) { FactoryBot.create(:member, registrant: registrant3) }
    let!(:competitor) { Competitor.create!(competition: competition, custom_name: "The 3 Jons", members: [member1, member2, member3]) }

    let(:rows) { described_class.new(competition).rows }

    let(:expected_row) do
      [
        "1, 2, 3",
        nil,
        "The 3 Jons",
        "United States",
        "(mixed)",
        "Senior"
      ]
    end

    it "includes the base information" do
      expect(rows.first).to eq(expected_row)
    end
  end
end
