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
    std.valid?.should == true
  end
  it "can be created from a CSV-based array" do
      s = StandardSkillEntry.new
      arr = ["307", "n", "4.8","jump mount to seat drag in back, feet holding seat"]
      s.initialize_from_array(arr)
      s.save!

      s = StandardSkillEntry.last
      s.number.should == 307
      s.letter == "n"
      s.points.should == 4.8
      s.description.should == 'jump mount to seat drag in back, feet holding seat'
  end

  it "displays a full description" do
    std = FactoryGirl.build(:standard_skill_entry)
    std.fullDescription.should == std.number.to_s + std.letter + " - riding - 8"
  end
  it "should be a non_riding_skill if >= 100" do
    std = FactoryGirl.build(:standard_skill_entry)
    std.non_riding_skill.should == false

    std = FactoryGirl.build(:standard_skill_entry, :number => 100)
    std.non_riding_skill.should == true
  end

  describe "with associated routine entries" do
    before(:each) do
      @entry = FactoryGirl.create(:standard_skill_routine_entry)
    end
    it "has associated entry" do
      skill = @entry.standard_skill_entry
      skill.standard_skill_routine_entries.should == [@entry]
    end
    it "removes the associated entry upon destroy" do
      skill = @entry.standard_skill_entry
      expect {
        skill.destroy
      }.to change(StandardSkillRoutineEntry, :count).by(-1)
    end
  end
end
