require 'spec_helper'

RSpec.describe AgeGroupCombiner do
  let(:age_group_type) { FactoryBot.create(:age_group_type) }
  let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }
  let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Female 10-20", start_age: 10, end_age: 20, gender: "Female") }
  let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Female 21-30", start_age: 21, end_age: 30, gender: "Female") }
  let!(:entry_3) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Female 31-40", start_age: 31, end_age: 40, gender: "Female") }
  let!(:male_entry) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Male 10-20", start_age: 10, end_age: 20, gender: "Male") }

  # reload, so that the age group type entries created above are loaded
  let(:combiner) { described_class.new(competition.reload) }

  describe "#combine" do
    it "creates a combination without modifying the age group entries" do
      original_attributes = [entry_1.reload, entry_2.reload].map(&:attributes)

      expect { combiner.combine(entry_1, entry_2) }.to change(AgeGroupCombination, :count).by(1)
      expect(AgeGroupEntry.count).to eq(4)
      expect([entry_1.reload, entry_2.reload].map(&:attributes)).to eq(original_attributes)
    end

    it "replaces the combined entries in the competition age groups" do
      combiner.combine(entry_2, entry_1)

      combination = competition.age_group_combinations.first
      expect(competition.age_groups).to eq([combination, entry_3, male_entry])
      expect(combination.to_s).to eq("Female 10-20 and Female 21-30")
      expect(combination.start_age).to eq(10)
      expect(combination.end_age).to eq(30)
    end

    it "extends an existing combination" do
      combiner.combine(entry_1, entry_2)
      combination = competition.age_group_combinations.first

      expect { combiner.combine(combination, entry_3) }.not_to change(AgeGroupCombination, :count)
      expect(combination.reload.age_group_entries).to contain_exactly(entry_1, entry_2, entry_3)
    end

    it "merges two combinations" do
      entry_4 = FactoryBot.create(:age_group_entry, age_group_type: age_group_type, short_description: "Female 41-50", start_age: 41, end_age: 50, gender: "Female")
      combiner.combine(entry_1, entry_2)
      combiner.combine(entry_3, entry_4)
      first_combination, second_combination = competition.age_groups.first(2)

      expect { combiner.combine(first_combination, second_combination) }.to change(AgeGroupCombination, :count).by(-1)
      expect(competition.age_groups.first.age_group_entries).to contain_exactly(entry_1, entry_2, entry_3, entry_4)
    end

    it "does not combine different genders" do
      expect(combiner.combine(entry_1, male_entry)).to be(false)
      expect(combiner.error_message).to eq("Age Groups must be the same gender")
    end

    it "does not combine non-contiguous age groups" do
      expect(combiner.combine(entry_1, entry_3)).to be(false)
      expect(combiner.error_message).to eq("Age Groups must be contiguous")
    end

    it "reports a concurrent combination instead of failing" do
      allow(AgeGroupCombinationEntry).to receive(:new).and_wrap_original do |original, *args, **kwargs|
        original.call(*args, **kwargs).tap { |entry| allow(entry).to receive(:save!).and_raise(ActiveRecord::RecordNotUnique) }
      end

      expect(combiner.combine(entry_1, entry_2)).to be(false)
      expect(combiner.error_message).to include("has just been combined")
      expect(AgeGroupCombination.count).to eq(0)
    end

    it "does not combine published age groups" do
      competition.published_age_group_entries.create!(age_group: entry_1)

      expect(combiner.combine(entry_1, entry_2)).to be(false)
      expect(combiner.error_message).to include("unpublish them first")
    end

    it "does not affect other competitions using the same age group type" do
      other_competition = FactoryBot.create(:timed_competition, age_group_type: age_group_type)
      combiner.combine(entry_1, entry_2)

      expect(other_competition.reload.age_groups).to eq([entry_1, entry_2, entry_3, male_entry])
    end

    it "ranks competitors of the combined entries in the combination" do
      competitor = FactoryBot.create(:event_competitor, competition: competition)
      competitor.update_column(:age_group_entry_id, entry_2.id)
      combiner.combine(entry_1, entry_2)

      combination = competition.age_group_combinations.first
      expect(competitor.reload.age_group).to eq(combination)
      expect(competition.competitors_in(combination)).to eq([competitor])
      expect(competitor.age_group_entry_description).to eq("Female 10-20 and Female 21-30")
    end
  end

  describe "#separate" do
    before { combiner.combine(entry_1, entry_2) }

    let(:combination) { competition.age_group_combinations.first }

    it "restores the original age groups" do
      expect(combiner.separate(combination)).to be(true)
      expect(competition.age_groups).to eq([entry_1, entry_2, entry_3, male_entry])
      expect(AgeGroupCombinationEntry.count).to eq(0)
    end

    it "does not separate a published combination" do
      competition.published_age_group_entries.create!(age_group: combination)

      expect(combiner.separate(combination)).to be(false)
      expect(AgeGroupCombination.count).to eq(1)
    end
  end

  describe "#smallest_neighbour" do
    let(:registrant_data) do
      [
        { gender: 'Female', age: 10, count: 2, ineligible: false },
        { gender: 'Female', age: 10, count: 4, ineligible: true },
        { gender: 'Female', age: 21, count: 1, ineligible: false },
        { gender: 'Female', age: 31, count: 10, ineligible: true },
        { gender: 'Male', age: 15, count: 5, ineligible: false }
      ]
    end

    it "can determine the smallest neighbour when first entry" do
      expect(combiner.smallest_neighbour(entry_1, registrant_data)).to eq(entry_2)
    end

    it "can determine the smallest neighbour when last entry" do
      expect(combiner.smallest_neighbour(entry_3, registrant_data)).to eq(entry_2)
    end

    it "can't determine the smallest neighbour when only entry" do
      expect(combiner.smallest_neighbour(male_entry, registrant_data)).to be_nil
    end

    it "can determine the smallest neighbour excluding ineligible registrants" do
      # There are 10 people in entry_3, but they are ineligible so we don't count them
      expect(combiner.smallest_neighbour(entry_2, registrant_data)).to eq(entry_3)
    end

    it "considers combinations as a single age group" do
      combiner.combine(entry_1, entry_2)

      expect(combiner.smallest_neighbour(entry_3, registrant_data)).to eq(competition.age_group_combinations.first)
    end
  end
end
