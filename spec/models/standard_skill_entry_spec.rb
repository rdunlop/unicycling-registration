# == Schema Information
#
# Table name: standard_skill_entries
#
#  id          :integer          not null, primary key
#  number      :integer
#  letter      :string(255)
#  points      :decimal(6, 2)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_standard_skill_entries_on_letter_and_number  (letter,number) UNIQUE
#

require 'spec_helper'

describe StandardSkillEntry do
  it "can save the necessary fields" do
    std = StandardSkillEntry.new
    std.number = 2
    std.letter = "a"
    std.points = 1.3
    std.description = "riding holding seatpost, one hand"
    expect(std.valid?).to eq(true)
  end
  it "can be created from a CSV-based array" do
    s = StandardSkillEntry.new
    arr = ["307", "n", "4.8", "jump mount to seat drag in back, feet holding seat"]
    s.initialize_from_array(arr)
    s.save!

    s = StandardSkillEntry.last
    expect(s.number).to eq(307)
    s.letter == "n"
    expect(s.points).to eq(4.8)
    expect(s.description).to eq('jump mount to seat drag in back, feet holding seat')
  end

  it "displays a full description" do
    std = FactoryGirl.build(:standard_skill_entry)
    expect(std.fullDescription).to eq(std.number.to_s + std.letter + " - riding - 8")
  end
  it "should be a non_riding_skill if >= 100" do
    std = FactoryGirl.build(:standard_skill_entry)
    expect(std.non_riding_skill).to eq(false)

    std = FactoryGirl.build(:standard_skill_entry, number: 100)
    expect(std.non_riding_skill).to eq(true)
  end

  describe "with associated routine entries" do
    before(:each) do
      @entry = FactoryGirl.create(:standard_skill_routine_entry)
    end
    it "has associated entry" do
      skill = @entry.standard_skill_entry
      expect(skill.standard_skill_routine_entries).to eq([@entry])
    end
    it "removes the associated entry upon destroy" do
      skill = @entry.standard_skill_entry
      expect {
        skill.destroy
      }.to change(StandardSkillRoutineEntry, :count).by(-1)
    end
  end
end
