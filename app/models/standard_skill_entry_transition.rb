# == Schema Information
#
# Table name: standard_skill_entry_transitions
#
#  id          :integer          not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class StandardSkillEntryTransition < ApplicationRecord
  validates :description, presence: true

  def to_s
    description
  end
end
