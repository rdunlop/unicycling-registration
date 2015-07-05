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

class StandardSkillEntry < ActiveRecord::Base
  has_many :standard_skill_routine_entries, dependent: :destroy

  validates :number, :points, :description, presence: true
  validates :letter, presence: true, uniqueness: {scope: :number } # not allowed to have the same number/letter pair twice

  default_scope { order('number, letter') }

  def initialize_from_array(arr)
    self.number      = arr[0].to_i
    self.letter      = arr[1]
    self.points      = arr[2]
    self.description = arr[3]
  end

  def fullDescription
    skill_number_and_letter + " - " + description
  end

  def skill_number_and_letter
    number.to_s + "" + letter
  end

  def non_riding_skill
    number >= 100
  end

  def self.non_riding_skills
    where("standard_skill_entries.number >= 100")
  end

  def to_s
    fullDescription
  end
end
