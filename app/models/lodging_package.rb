# == Schema Information
#
# Table name: lodging_packages
#
#  id                     :integer          not null, primary key
#  lodging_room_type_id   :integer          not null
#  lodging_room_option_id :integer          not null
#  total_cost_cents       :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_lodging_packages_on_lodging_room_option_id  (lodging_room_option_id)
#  index_lodging_packages_on_lodging_room_type_id    (lodging_room_type_id)
#

class LodgingPackage < ApplicationRecord
  belongs_to :lodging_room_type
  belongs_to :lodging_room_option
  has_many :lodging_package_days, dependent: :destroy
  has_many :registrant_expense_items, as: :line_item, inverse_of: :line_item, dependent: :restrict_with_exception

  validates :lodging_room_type, :lodging_room_option, presence: true
  validates :total_cost, presence: true
  monetize :total_cost_cents

  def can_create_registrant_expense_item?(_registrant_expense_item)
    []
  end

  def has_custom_cost?
    false
  end

  def has_details?; end

  # alias_attribute :cost, :total_cost

  def tax
    0
  end
end
