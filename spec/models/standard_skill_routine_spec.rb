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
  before do
    @routine = FactoryBot.create(:standard_skill_routine)
  end

  it "is able to save an entry" do
    skill = FactoryBot.create(:standard_skill_entry)
    @routine.standard_skill_routine_entries.build(
      position: 1,
      standard_skill_entry_id: skill.id
    )
    expect(@routine.valid?).to eq(true)
  end

  it "is not able to save more than 18 entries per user" do
    18.times do |_i|
      skill = FactoryBot.create(:standard_skill_entry)
      @routine.standard_skill_routine_entries.create(position: 1, standard_skill_entry_id: skill.id)
    end
    expect(@routine.valid?).to eq(true)
    skill = FactoryBot.create(:standard_skill_entry)
    ssre = @routine.standard_skill_routine_entries.build(position: 1, standard_skill_entry_id: skill.id)

    expect(ssre.valid?).to eq(false)
    expect(@routine.valid?).to eq(false)
  end

  describe "with a routine containing 12 skills > 100" do
    before do
      12.times do |i|
        skill = FactoryBot.create(:standard_skill_entry, number: (100 + i))
        @routine.standard_skill_routine_entries.create(
          position: i,
          standard_skill_entry_id: skill.id
        )
      end
    end

    it "does not allow a 13th entry with skill > 100" do
      skill = FactoryBot.create(:standard_skill_entry, number: 101)
      ssre = @routine.standard_skill_routine_entries.build(position: 1, standard_skill_entry_id: skill.id)
      expect(@routine.valid?).to eq(false)
      expect(ssre.valid?).to eq(false)
    end

    it "allows a 13th entry with skill < 100" do
      skill = FactoryBot.create(:standard_skill_entry, number: 10)
      ssre = @routine.standard_skill_routine_entries.build(position: 1, standard_skill_entry_id: skill.id)
      expect(@routine.valid?).to eq(true)
      expect(ssre.valid?).to eq(true)
    end
  end

  it "is not able to have 2 skills with the same number" do
    skill = FactoryBot.create(:standard_skill_entry)
    @routine.standard_skill_routine_entries.create(
      position: 1,
      standard_skill_entry_id: skill.id
    )

    expect(@routine.valid?).to eq(true)

    ssre = @routine.standard_skill_routine_entries.build(
      position: 2,
      standard_skill_entry_id: skill.id
    )

    expect(ssre.valid?).to eq(false)
    expect(@routine.valid?).to eq(false)
  end

  it "is not able to have 2 skills with the same number, but different letters" do
    skill1 = FactoryBot.create(:standard_skill_entry, number: 1, letter: 'a')
    skill2 = FactoryBot.create(:standard_skill_entry, number: 1, letter: 'b')
    @routine.standard_skill_routine_entries.create!(
      position: 1,
      standard_skill_entry_id: skill1.id
    )

    expect(@routine.valid?).to eq(true)

    ssre = @routine.standard_skill_routine_entries.build(
      position: 2,
      standard_skill_entry_id: skill2.id
    )

    expect(ssre.valid?).to eq(false)
    expect(@routine.valid?).to eq(false)

    expect(ssre.errors.count).to eq(1)
  end

  it "is able to total up some scores" do
    skill1 = FactoryBot.create(:standard_skill_entry, points: 1.1)
    skill2 = FactoryBot.create(:standard_skill_entry, points: 2.2)
    @routine.standard_skill_routine_entries.create(
      position: 1,
      standard_skill_entry_id: skill1.id
    )
    @routine.standard_skill_routine_entries.create(
      position: 2,
      standard_skill_entry_id: skill2.id
    )

    expect(@routine.valid?).to eq(true)

    expect(@routine.total_skill_points).to eq(3.3)
  end

  it "destroys associated standard_skill_routine_entry upon destroy" do
    FactoryBot.create(:standard_skill_routine_entry, standard_skill_routine: @routine)

    @routine.reload

    expect(StandardSkillRoutineEntry.count).to eq(1)

    @routine.destroy

    expect(StandardSkillRoutineEntry.count).to eq(0)
  end
end
