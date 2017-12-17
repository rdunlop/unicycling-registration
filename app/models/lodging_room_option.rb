# == Schema Information
#
# Table name: lodging_room_options
#
#  id                   :integer          not null, primary key
#  lodging_room_type_id :integer          not null
#  position             :integer
#  name                 :string           not null
#  price_cents          :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_lodging_room_options_on_lodging_room_type_id  (lodging_room_type_id)
#

class LodgingRoomOption < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { scope: [:lodging_room_type_id] }

  belongs_to :lodging_room_type, inverse_of: :lodging_room_options
  has_many :lodging_days, dependent: :destroy

  acts_as_restful_list scope: :lodging_room_type
  accepts_nested_attributes_for :lodging_days, allow_destroy: true
  # validates_uniqueness :lodging_days, attribute_name: :date_offered

  scope :ordered, -> { order(:position) }

  monetize :price_cents

  def to_s
    name
  end
end
