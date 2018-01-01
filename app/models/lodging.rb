# == Schema Information
#
# Table name: lodgings
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  position    :integer
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Lodging < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :lodging_room_types, inverse_of: :lodging, dependent: :restrict_with_error
  has_many :lodging_room_options, through: :lodging_room_types
  has_many :lodging_days, through: :lodging_types

  accepts_nested_attributes_for :lodging_room_types, allow_destroy: true
  validates_uniqueness :lodging_room_types, attribute_name: :name

  acts_as_restful_list

  scope :ordered, -> { order(:position) }

  def to_s
    name
  end
end
