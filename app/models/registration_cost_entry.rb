# == Schema Information
#
# Table name: registration_cost_entries
#
#  id                   :integer          not null, primary key
#  registration_cost_id :integer          not null
#  expense_item_id      :integer          not null
#  min_age              :integer
#  max_age              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_registration_cost_entries_on_registration_cost_id  (registration_cost_id)
#

class RegistrationCostEntry < ApplicationRecord
  validates :registration_cost, presence: true
  validates :expense_item, presence: true

  belongs_to :registration_cost, inverse_of: :registration_cost_entries
  validates :min_age, :max_age, absence: true, if: proc { |el| el.registration_cost.registrant_type != "competitor" }

  belongs_to :expense_item, dependent: :destroy
  accepts_nested_attributes_for :expense_item

  def to_s
    [registration_cost.to_s_with_type, age_description].compact.join(" ")
  end

  def valid_for?(age)
    return true if min_age.blank? && max_age.blank?

    if min_age.blank?
      age <= max_age
    elsif max_age.blank?
      min_age <= age
    else
      min_age <= age && age <= max_age
    end
  end

  def age_description
    if min_age.present? && max_age.present?
      "(Ages #{min_age}-#{max_age})"
    elsif min_age.present?
      "(Ages #{min_age}+)"
    elsif max_age.present?
      "(Ages < #{max_age})"
    end
  end
end
