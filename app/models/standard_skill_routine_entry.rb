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

class StandardSkillRoutineEntry < ApplicationRecord
  belongs_to :standard_skill_entry
  belongs_to :standard_skill_routine
  acts_as_restful_list scope: :standard_skill_routine
  has_many :standard_skill_score_entries, dependent: :restrict_with_exception

  validates :standard_skill_entry_id, :standard_skill_routine_id, presence: true
  validates :position, presence: true, numericality: {only_integer: true}

  validate :no_more_than_18_skill_entries
  validate :no_more_than_12_non_riding_skills
  validate :each_skill_must_be_different_number

  delegate :skill_number_and_letter, :points, to: :standard_skill_entry

  delegate :description, to: :standard_skill_entry

  # Does this Standard Skill Score Entry have any Judged Scores?
  def judge_scores?
    standard_skill_score_entries.any?
  end

  def add_standard_skill_routine_entry(params)
    # keep the position values between 1 and 18
    if standard_skill_routine_entries.size > 1
      # if the user doesn't specify a position, default to 'end of list'
      if params[:position].nil? || params[:position].empty? || params[:position].to_i > standard_skill_routine_entries.last.position + 1
        params[:position] = standard_skill_routine_entries.last.position + 1
      elsif params[:position].to_i < 1
        params[:position] = 1
      end
    elsif params[:position].nil? || params[:position].empty?
      params[:position] = 1
    end
    standard_skill_routine_entries.build(params)
  end

  private

  def no_more_than_18_skill_entries
    # XXX should not traverse this 'standard_skill_routine' object?
    if standard_skill_routine.standard_skill_routine_entries.count >= 18
      if new_record?
        errors[:base] << "You cannot specify more than 18 entries in your skills routine"
      end
    end
  end

  def no_more_than_12_non_riding_skills
    count = 0
    standard_skill_routine.standard_skill_routine_entries.each do |skill|
      if skill.standard_skill_entry.non_riding_skill
        count += 1
      end
    end
    if count > 12
      if new_record?
        errors[:base] << "You cannot have more than 12 non-riding-skills (skills above 100)"
      end
    end
  end

  def each_skill_must_be_different_number
    if new_record?
      standard_skill_routine.standard_skill_routine_entries.each do |first_entry|
        if first_entry.standard_skill_entry.number == standard_skill_entry.number
          errors[:base] << "You cannot have 2 skills with the same number (#{first_entry.standard_skill_entry.number})"
        end
      end
    end
  end
end
