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

  describe "locking the age group type" do
    it "is combined" do
      expect(age_group_type).to be_combined
      expect(age_group_type.age_group_combinations).to eq([combination])
    end

    it "prevents modifying a combined entry" do
      expect(entry_2.update(start_age: 12)).to be(false)
      expect(entry_2.errors[:base].first).to include("cannot be modified", "#{competition}: #{combination}")
      expect(entry_2.reload.start_age).to eq(11)
    end

    it "prevents modifying an uncombined entry" do
      expect(entry_3.update(short_description: "Seniors")).to be(false)
    end

    it "prevents adding an entry" do
      new_entry = FactoryBot.build(:age_group_entry, age_group_type: age_group_type.reload, start_age: 31, end_age: 40)

      expect(new_entry.save).to be(false)
    end

    it "prevents removing an entry" do
      expect(entry_2.destroy).to be(false)
      expect(AgeGroupEntry.exists?(entry_2.id)).to be(true)
      expect(AgeGroupCombinationEntry.count).to eq(2)
    end

    it "prevents reordering the entries" do
      expect(entry_3.update(position: 1)).to be(false)
    end

    it "reports a single error in the age group type form" do
      result = age_group_type.reload.update(age_group_entries_attributes: [
                                              { id: entry_2.id, start_age: 12 },
                                              { id: entry_3.id, _destroy: "1" }
                                            ])

      expect(result).to be(false)
      expect(age_group_type.errors.full_messages).to eq([age_group_type.combined_error])
      expect(age_group_type.combined_error).to include("Separate these combinations, or duplicate this age group type")
      expect(AgeGroupEntry.exists?(entry_3.id)).to be(true)
    end

    it "allows renaming the age group type" do
      expect(age_group_type.reload.update(name: "Renamed")).to be(true)
    end

    it "is lifted once the combinations are separated" do
      combination.destroy

      expect(entry_2.reload.update(start_age: 12)).to be(true)
    end

    it "does not lock a duplicate of the age group type" do
      duplicator = AgeGroupTypeDuplicator.new(age_group_type.reload)
      duplicator.duplicate
      duplicate = duplicator.new_age_group_type

      expect(duplicate).not_to be_combined
      expect(duplicate.age_group_entries.first.update(start_age: 1)).to be(true)
    end
  end

  describe "naming" do
    it "uses the names of the combined entries by default" do
      expect(combination.short_description).to eq("#{entry_1.short_description} and #{entry_2.short_description}")
    end

    it "can have a custom name" do
      combination.update!(name: "  Juniors  ")

      expect(combination.name).to eq("Juniors")
      expect(combination.to_s).to eq("Juniors")
      expect(combination.generated_name).to eq("#{entry_1.short_description} and #{entry_2.short_description}")
    end

    it "restores the default name with a blank name" do
      combination.update!(name: "Juniors")
      combination.update!(name: " ")

      expect(combination.name).to be_nil
      expect(combination.short_description).to eq(combination.generated_name)
    end

    it "does not keep the default name as a custom name" do
      combination.update!(name: combination.generated_name)

      expect(combination.name).to be_nil
    end

    it "cannot have the name of another age group of the competition, as they would be ranked together" do
      expect(combination.update(name: entry_3.short_description)).to be(false)
      expect(combination.errors[:name]).to be_present
    end
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
#  name           :string
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
