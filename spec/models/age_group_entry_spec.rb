# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string
#  start_age         :integer
#  end_age           :integer
#  gender            :string
#  created_at        :datetime
#  updated_at        :datetime
#  wheel_size_id     :integer
#  position          :integer
#
# Indexes
#
#  age_type_desc                              (age_group_type_id,short_description) UNIQUE
#  index_age_group_entries_age_group_type_id  (age_group_type_id)
#  index_age_group_entries_wheel_size_id      (wheel_size_id)
#

require 'spec_helper'

describe AgeGroupEntry do
  before do
    @age_group_entry = FactoryBot.build_stubbed(:age_group_entry)
  end

  it { is_expected.to validate_uniqueness_of(:short_description).scoped_to(:age_group_type_id) }

  it "can be created by factorygirl" do
    expect(@age_group_entry.valid?).to eq(true)
  end

  it "requires an age_group_type" do
    @age_group_entry.age_group_type_id = nil
    expect(@age_group_entry.valid?).to eq(false)
  end

  it "requires a short_description" do
    @age_group_entry.short_description = nil
    expect(@age_group_entry.valid?).to eq(false)
  end

  it "can have the same short_description, as long as it has a different age_group_type" do
    age2 = FactoryBot.build(:age_group_entry, short_description: @age_group_entry.short_description)
    expect(age2.valid?).to eq(true)
  end

  it "has a wheel_size" do
    @age_group_entry.wheel_size = FactoryBot.build_stubbed(:wheel_size)
  end

  it "requires gender be valid" do
    @age_group_entry.gender = nil
    expect(@age_group_entry.valid?).to eq(false)

    @age_group_entry.gender = "Male"
    expect(@age_group_entry.valid?).to eq(true)

    @age_group_entry.gender = "Female"
    expect(@age_group_entry.valid?).to eq(true)

    @age_group_entry.gender = "Mixed"
    expect(@age_group_entry.valid?).to eq(true)

    @age_group_entry.gender = "Other"
    expect(@age_group_entry.valid?).to eq(false)
  end

  describe "#smallest_neighbour" do
    let!(:female_age_group_type) { FactoryBot.create(:age_group_type) }
    let!(:age_group_entry_1) { FactoryBot.create(:age_group_entry, age_group_type: female_age_group_type, start_age: 10, end_age: 20, gender: 'Female') }
    let!(:age_group_entry_2) { FactoryBot.create(:age_group_entry, age_group_type: female_age_group_type, start_age: 21, end_age: 30, gender: 'Female') }
    let!(:age_group_entry_3) { FactoryBot.create(:age_group_entry, age_group_type: female_age_group_type, start_age: 31, end_age: 40, gender: 'Female') }
    let!(:male_age_group_type) { FactoryBot.create(:age_group_type) }
    let!(:age_group_entry_4) { FactoryBot.create(:age_group_entry, age_group_type: male_age_group_type, start_age: 10, end_age: 20, gender: 'Male') }
    let(:registrant_data) do
      [
        {
          gender: 'Female',
          age: 10,
          count: 2,
          ineligible: false
        },
        {
          gender: 'Female',
          age: 10,
          count: 4,
          ineligible: true
        },
        {
          gender: 'Female',
          age: 21,
          count: 1,
          ineligible: false
        },
        {
          gender: 'Female',
          age: 31,
          count: 10,
          ineligible: true
        },
        {
          gender: 'Male',
          age: 15,
          count: 5,
          ineligible: false
        }
      ]
    end

    it "can determine the smallest neighbour when first entry" do
      expect(age_group_entry_1.smallest_neighbour(registrant_data)).not_to be_nil
      expect(age_group_entry_1.smallest_neighbour(registrant_data)).to eq(age_group_entry_2)
    end

    it "can determine the smallest neighbour when last entry" do
      expect(age_group_entry_3.smallest_neighbour(registrant_data)).not_to be_nil
      expect(age_group_entry_3.smallest_neighbour(registrant_data)).to eq(age_group_entry_2)
    end

    it "can't determine the smallest neighbour when only entry" do
      expect(age_group_entry_4.smallest_neighbour(registrant_data)).to be_nil
    end

    it "can determine the smallest neighbour excluding ineligible registrants" do
      expect(age_group_entry_2.smallest_neighbour(registrant_data)).not_to be_nil
      # There are 10 people in age_group_entry_3, but they are ineligible so we don't count them
      expect(age_group_entry_2.smallest_neighbour(registrant_data)).to eq(age_group_entry_3)
    end
  end

  describe "Number matching registrant" do
    let!(:age_group_type) { FactoryBot.create(:age_group_type) }
    let!(:age_group_entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 10, end_age: 20, gender: 'Male') }
    let!(:age_group_entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 21, end_age: 30, gender: 'Male') }
    let(:registrant_data) do
      [
        {
          gender: 'Male',
          age: 10,
          count: 2,
          ineligible: false
        },
        {
          gender: 'Male',
          age: 10,
          count: 4,
          ineligible: true
        },
        {
          gender: 'Male',
          age: 21,
          count: 1,
          ineligible: false
        },
        {
          gender: 'Female',
          age: 15,
          count: 5,
          ineligible: false
        }
      ]
    end

    describe "without eligibility restriction" do
      it "includes only registrants matching the criteria" do
        result = age_group_entry_1.number_matching_registrant(registrant_data)

        expect(result).not_to be_nil
        expect(result).to eq(6)
      end
    end

    describe "including only eligible registrants" do
      it "includes only registrants matching the criteria" do
        result = age_group_entry_1.number_eligible_matching_registrant(registrant_data)

        expect(result).not_to be_nil
        expect(result).to eq(2)
      end
    end

    describe "including only ineligible registrants" do
      it "includes only registrants matching the criteria" do
        result = age_group_entry_1.number_ineligible_matching_registrant(registrant_data)

        expect(result).not_to be_nil
        expect(result).to eq(4)
      end
    end
  end
end
