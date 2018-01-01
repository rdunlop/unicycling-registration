# == Schema Information
#
# Table name: lodging_room_types
#
#  id                :integer          not null, primary key
#  lodging_id        :integer          not null
#  position          :integer
#  name              :string           not null
#  description       :text
#  visible           :boolean          default(TRUE), not null
#  maximum_available :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_lodging_room_types_on_lodging_id  (lodging_id)
#

class LodgingRoomType < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: [:lodging_id] }

  belongs_to :lodging, inverse_of: :lodging_room_types
  has_many :lodging_room_options, dependent: :destroy
  has_many :lodging_packages, inverse_of: :lodging_room_type

  accepts_nested_attributes_for :lodging_room_options, allow_destroy: true

  acts_as_restful_list scope: :lodging

  scope :ordered, -> { order(:position) }

  def to_s
    name
  end

  def num_selected_items(lodging_day)
    lodging_room_options.map do |lodging_room_option|
      lodging_room_option.num_selected_items(lodging_day)
    end.sum
  end

  def maximum_reached?(lodging_day)
    return false unless has_limits?

    num_selected_items(lodging_day) >= maximum_available
  end

  def has_limits?
    return true if maximum_available&.positive?
    false
  end
end
