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
  has_many :payment_details, as: :line_item, dependent: :restrict_with_exception

  validates :lodging_room_type, :lodging_room_option, presence: true
  validates :total_cost, presence: true
  monetize :total_cost_cents

  # Check to see that a new entry can be created
  def can_create_registrant_expense_item?(registrant_expense_item)
    errors = []

    # Check to see if the registrant has already booked a Lodging for the same day as they are trying to book
    existing_packages = registrant_expense_item.registrant.all_line_items.select{ |line_item| line_item.is_a?(LodgingPackage) }
    lodging_package_days.each do |lodging_package_day|
      if existing_packages.flat_map(&:lodging_package_days).map(&:date_offered).include?(lodging_package_day.date_offered)
        errors << "Unable to add the same day (#{lodging_package_day.date_offered}) twice"
      end
    end

    # Check to see if any of the lodging_days that they are trying to book are full.
    lodging_package_days.each do |lodging_package_day|
      if lodging_room_type.maximum_reached?(lodging_package_day.lodging_day)
        errors << "#{lodging_package_day} Unable to be booked. None Left"
      end
    end

    errors
  end

  def has_custom_cost?
    false
  end

  def has_details?; end

  alias_attribute :cost, :total_cost

  def tax
    0
  end

  def to_s
    LodgingPackagePresenter.new(self).to_s
  end

  def status
    if registrant_expense_items.any?
      "Selected"
    elsif payment_details.any?
      "Sold"
    else
      "Error"
    end
  end

  def registrant
    associated_entry&.registrant
  end

  def date_of_last_activity
    associated_entry&.updated_at
  end

  private

  def associated_entry
    if registrant_expense_items.any?
      registrant_expense_items.first
    elsif payment_details.any?
      payment_details.first
    end
  end
end
