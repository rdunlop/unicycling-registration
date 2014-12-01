# == Schema Information
#
# Table name: standard_skill_routines
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_standard_skill_routines_on_registrant_id  (registrant_id) UNIQUE
#

require 'spec_helper'

describe StandardSkillRoutine do
  before(:each) do
    @routine = FactoryGirl.create(:standard_skill_routine)
  end

  it "should be able to save an entry" do
    skill = FactoryGirl.create(:standard_skill_entry)
    entry = @routine.standard_skill_routine_entries.build(
      :position => 1,
      :standard_skill_entry_id => skill.id)
      @routine.valid?.should == true
  end
  it "should not be able to save more than 18 entries per user" do
    18.times do |i|
      skill = FactoryGirl.create(:standard_skill_entry)
      @routine.standard_skill_routine_entries.create(:position => 1, :standard_skill_entry_id => skill.id)
    end
    @routine.valid?.should == true
    skill = FactoryGirl.create(:standard_skill_entry)
    ssre = @routine.standard_skill_routine_entries.build(:position => 1, :standard_skill_entry_id => skill.id)

    ssre.valid?.should == false
    @routine.valid?.should == false
  end

  describe "with a routine containing 12 skills > 100" do
    before(:each) do
      12.times do |i|
        skill = FactoryGirl.create(:standard_skill_entry, number: (100 + i))
        @routine.standard_skill_routine_entries.create(
          :position => i,
          :standard_skill_entry_id => skill.id)
      end
    end
    it "should not allow a 13th entry with skill > 100" do
      skill = FactoryGirl.create(:standard_skill_entry, number: 101)
      ssre = @routine.standard_skill_routine_entries.build(:position => 1, :standard_skill_entry_id => skill.id)
      @routine.valid?.should == false
      ssre.valid?.should == false
    end

    it "should allow a 13th entry with skill < 100" do
      skill = FactoryGirl.create(:standard_skill_entry, number: 10)
      ssre = @routine.standard_skill_routine_entries.build(:position => 1, :standard_skill_entry_id => skill.id)
      @routine.valid?.should == true
      ssre.valid?.should == true
    end
  end

  it "should not be able to have 2 skills with the same number" do
    skill = FactoryGirl.create(:standard_skill_entry)
    @routine.standard_skill_routine_entries.create(
      :position => 1,
      :standard_skill_entry_id => skill.id)

      @routine.valid?.should == true

      ssre = @routine.standard_skill_routine_entries.build(
        :position => 2,
        :standard_skill_entry_id => skill.id)

        ssre.valid?.should == false
        @routine.valid?.should == false
  end

  it "should not be able to have 2 skills with the same number, but different letters" do
    skill1 = FactoryGirl.create(:standard_skill_entry, :number => 1, :letter => 'a')
    skill2 = FactoryGirl.create(:standard_skill_entry, :number => 1, :letter => 'b')
    @routine.standard_skill_routine_entries.create!(
      :position => 1,
      :standard_skill_entry_id => skill1.id)

      @routine.valid?.should == true

      ssre = @routine.standard_skill_routine_entries.build(
        :position => 2,
        :standard_skill_entry_id => skill2.id)

        ssre.valid?.should == false
        @routine.valid?.should == false

        ssre.errors.count.should == 1
  end
  it "should be able to total up some scores" do
    skill1 = FactoryGirl.create(:standard_skill_entry, :points => 1.1)
    skill2 = FactoryGirl.create(:standard_skill_entry, :points => 2.2)
    @routine.standard_skill_routine_entries.build(
      :position => 1,
      :standard_skill_entry_id => skill1.id)
      @routine.standard_skill_routine_entries.build(
        :position => 2,
        :standard_skill_entry_id => skill2.id)

        @routine.valid?.should == true

        @routine.total_skill_points.should == 3.3
  end

  it "destroys associated standard_skill_routine_entry upon destroy" do
    skill = FactoryGirl.create(:standard_skill_routine_entry, :standard_skill_routine => @routine)

    @routine.reload

    StandardSkillRoutineEntry.count.should == 1

    @routine.destroy

    StandardSkillRoutineEntry.count.should == 0
  end
end
