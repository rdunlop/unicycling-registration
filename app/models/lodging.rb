# == Schema Information
#
# Table name: lodgings
#
#  id          :bigint           not null, primary key
#  position    :integer
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#
# Indexes
#
#  index_lodgings_on_visible  (visible)
#

class Lodging < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  has_many :lodging_room_types, inverse_of: :lodging, dependent: :restrict_with_error
  has_many :lodging_room_options, through: :lodging_room_types
  has_many :lodging_days, through: :lodging_types

  def ordered_lodging_room_options
    lodging_room_options.merge(LodgingRoomType.ordered).merge(LodgingRoomOption.ordered)
  end

  accepts_nested_attributes_for :lodging_room_types, allow_destroy: true
  validates_uniqueness :lodging_room_types, attribute_name: :name

  acts_as_restful_list

  scope :ordered, -> { order(:position) }

  scope :active, -> { where(visible: true) }

  def to_s
    name
  end
end
