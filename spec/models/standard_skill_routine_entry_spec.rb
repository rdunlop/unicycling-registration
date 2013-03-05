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
    skr.standard_skill_entry.description.should == "riding - 8"
  end
end
