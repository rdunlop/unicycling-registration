# == Schema Information
#
# Table name: standard_skill_entry_additional_descriptions
#
#  id          :integer          not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class StandardSkillEntryAdditionalDescription < ActiveRecord::Base
  validates :description, presence: true

  def to_s
    description
  end
end
