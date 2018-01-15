# == Schema Information
#
# Table name: expense_group_options
#
#  id               :integer          not null, primary key
#  expense_group_id :integer          not null
#  registrant_type  :string           not null
#  option           :string           not null
#  min_age          :integer
#  max_age          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_expense_group_options_on_expense_group_id  (expense_group_id)
#

class ExpenseGroupOption < ApplicationRecord
  belongs_to :expense_group, inverse_of: :expense_group_options
  validates :registrant_type, presence: true, inclusion: { in: ["competitor", "noncompetitor"] }

  def self.options
    ["One Free In Group", "One In Group REQUIRED", "One Free of Each In Group"]
  end

  validates :option, inclusion: { in: options }
  validates :min_age, :max_age, absence: true, if: proc { |el| el.registrant_type == "spectator" }

  def self.for(registrant_type, registrant_age)
    where(registrant_type: registrant_type).select do |group_options|
      group_options.valid_for?(registrant_age)
    end
  end

  def no_ages?
    min_age.blank? && max_age.blank?
  end

  def valid_for?(registrant_age)
    return true if no_ages?

    return false if min_age.present? && registrant_age < min_age
    return false if max_age.present? && max_age < registrant_age

    true
  end
end
