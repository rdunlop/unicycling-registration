class ExpenseGroupFreeOption < ApplicationRecord
  belongs_to :expense_group, inverse_of: :expense_group_free_options
  validates :registrant_type, presence: true, inclusion: { in: ["competitor", "noncompetitor"] }

  def self.free_options
    ["One Free In Group", "One Free In Group REQUIRED", "One Free of Each In Group"]
  end

  validates :free_option, inclusion: { in: free_options }
  validates :min_age, :max_age, absence: true, if: proc { |el| el.registrant_type != "competitor" }

  def self.for(registrant_type, registrant_age)
    where(registrant_type: registrant_type).select do |group_free_option|
      group_free_option.valid_for?(registrant_age)
    end
  end

  def has_no_ages?
    min_age.blank? && max_age.blank?
  end

  def valid_for?(registrant_age)
    return true if has_no_ages?

    return false if min_age.present? && registrant_age < min_age
    return false if max_age.present? && max_age < registrant_age

    true
  end
end
