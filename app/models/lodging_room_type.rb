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
  accepts_nested_attributes_for :lodging_room_options, allow_destroy: true

  acts_as_restful_list scope: :lodging

  scope :ordered, -> { order(:position) }

  def to_s
    name
  end
end
