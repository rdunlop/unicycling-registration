# == Schema Information
#
# Table name: standard_skill_routine_entries
#
#  id                        :integer          not null, primary key
#  standard_skill_routine_id :integer
#  standard_skill_entry_id   :integer
#  position                  :integer
#  created_at                :datetime
#  updated_at                :datetime
#

require 'spec_helper'

describe StandardSkillRoutineEntry do
  it "should be able to reference the associated skill entry" do
    skill = FactoryGirl.create(:standard_skill_entry)
    routine = FactoryGirl.create(:standard_skill_routine)
    skr = StandardSkillRoutineEntry.new
    skr.standard_skill_entry = skill
    skr.standard_skill_routine = routine
    skr.position = 2
    skr.save!

    skr = StandardSkillRoutineEntry.last
    expect(skr.standard_skill_entry.description).to eq("riding - 8")
  end
end
