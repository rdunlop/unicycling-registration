# == Schema Information
#
# Table name: age_group_entries
#
#  id                :integer          not null, primary key
#  age_group_type_id :integer
#  short_description :string(255)
#  start_age         :integer
#  end_age           :integer
#  gender            :string(255)
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
  before(:each) do
    @age_group_entry = FactoryGirl.build_stubbed(:age_group_entry)
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
    age2 = FactoryGirl.build(:age_group_entry, short_description: @age_group_entry.short_description)
    expect(age2.valid?).to eq(true)
  end

  it "has a wheel_size" do
    @age_group_entry.wheel_size = FactoryGirl.build_stubbed(:wheel_size)
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
    let!(:age_group_type) { FactoryGirl.create(:age_group_type) }
    let!(:age_group_entry_1) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }
    let!(:age_group_entry_2) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }
    let(:registrant_data) do
      {
        gender: 'male',
        age: 10
      }
    end

    it "can determine the smallest neighbour" do
      expect(age_group_entry_1.smallest_neighbour(registrant_data)).not_to be_nil
      expect(age_group_entry_1.smallest_neighbour(registrant_data)).to eq(age_group_entry_2)
    end
  end
end
