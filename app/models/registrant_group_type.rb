# == Schema Information
#
# Table name: registrant_group_types
#
#  id                    :integer          not null, primary key
#  source_element_type   :string           not null
#  source_element_id     :integer          not null
#  notes                 :string
#  max_members_per_group :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class RegistrantGroupType < ApplicationRecord
  belongs_to :source_element, polymorphic: true

  has_many :registrant_groups, dependent: :restrict_with_error, inverse_of: :registrant_group_type
  has_many :registrants, through: :registrant_groups

  validates :source_element, presence: true

  delegate :to_s, to: :source_element
end
