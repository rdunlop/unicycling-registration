require 'spec_helper'

describe AgeGroupCombination do
  let(:age_group_type) { FactoryBot.create(:age_group_type) }
  let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }
  let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 0, end_age: 10) }
  let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 11, end_age: 20) }
  let!(:entry_3) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 21, end_age: 30) }
  let!(:combination) do
    combination = competition.age_group_combinations.create!
    combination.age_group_combination_entries.create!(age_group_entry: entry_1)
    combination.age_group_combination_entries.create!(age_group_entry: entry_2)
    combination
  end

  # reload, so that the age group type entries created above are loaded
  before { competition.reload }

  it "does not allow an entry to be in two combinations of the same competition" do
    other_combination = competition.age_group_combinations.create!

    expect(other_combination.age_group_combination_entries.build(age_group_entry: entry_1)).not_to be_valid
  end

  it "is named after the combined entries" do
    expect(combination.short_description).to eq("#{entry_1.short_description} and #{entry_2.short_description}")
  end

  it "is unique per competition in the database" do
    other_combination = competition.age_group_combinations.create!
    combination_entry = other_combination.age_group_combination_entries.build(age_group_entry: entry_1, competition: competition)

    expect { combination_entry.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "is removed when the competition changes its age group type" do
    competition.update!(age_group_type: FactoryBot.create(:age_group_type))

    expect(described_class.count).to eq(0)
  end

  it "prevents the competition from changing its age group type while published" do
    competition.published_age_group_entries.create!(age_group: combination)

    expect(competition.update(age_group_type: FactoryBot.create(:age_group_type))).to be(false)
    expect(competition.errors[:age_group_type_id]).to be_present
    expect(described_class.count).to eq(1)
  end

  describe "caching" do
    it "loads the combinations once for all instances of the competition" do
      Competition.find(competition.id).age_group_for(entry_1)

      queries = []
      callback = ->(*, payload) { queries << payload[:sql] if payload[:sql].include?("age_group_combination") }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        expect(Competition.find(competition.id).age_group_for(entry_1)).to eq(combination)
      end
      expect(queries).to be_empty
    end

    it "is refreshed when the combination changes" do
      expect(competition.age_group_for(entry_3)).to eq(entry_3)

      combination.age_group_combination_entries.create!(age_group_entry: entry_3)

      expect(competition.age_group_for(entry_3)).to eq(combination)
    end
  end

  describe "Competition#age_group_for" do
    it "returns the combination of a combined entry" do
      expect(competition.age_group_for(entry_1)).to eq(combination)
    end

    it "returns an uncombined entry itself" do
      expect(competition.age_group_for(entry_3)).to eq(entry_3)
    end
  end

  describe "Competition#find_age_group" do
    it "finds uncombined entries by id, as in URLs prior to combinations" do
      expect(competition.find_age_group(entry_3.id.to_s)).to eq(entry_3)
      expect(competition.find_age_group(entry_1.id.to_s)).to be_nil
    end

    it "finds age groups by param" do
      expect(competition.find_age_group(combination.to_age_group_param)).to eq(combination)
      expect(competition.find_age_group(entry_3.to_age_group_param)).to eq(entry_3)
    end

    it "does not find combined entries" do
      expect(competition.find_age_group(entry_1.to_age_group_param)).to be_nil
    end
  end
end

# == Schema Information
#
# Table name: age_group_combinations
#
#  id             :bigint           not null, primary key
#  competition_id :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_age_group_combinations_on_competition_id  (competition_id)
#
# Foreign Keys
#
#  fk_rails_...  (competition_id => competitions.id)
#
