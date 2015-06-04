# == Schema Information
#
# Table name: registrant_expense_items
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  expense_item_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#  details           :string(255)
#  free              :boolean          default(FALSE), not null
#  system_managed    :boolean          default(FALSE), not null
#  locked            :boolean          default(FALSE), not null
#  custom_cost_cents :integer
#
# Indexes
#
#  index_registrant_expense_items_expense_item_id  (expense_item_id)
#  index_registrant_expense_items_registrant_id    (registrant_id)
#

class RegistrantExpenseItem < ActiveRecord::Base
  include CachedSetModel
  include HasDetailsDescription

  belongs_to :registrant, touch: true
  belongs_to :expense_item, inverse_of: :registrant_expense_items

  has_paper_trail meta: { registrant_id: :registrant_id }

  validates :expense_item, :registrant, presence: true
  validate :only_one_free_per_expense_group, on: :create
  validate :no_more_than_max_per_registrant, on: :create
  validate :custom_cost_present

  monetize :custom_cost_cents, allow_nil: true

  delegate :has_details?, :details_label, to: :expense_item

  def self.cache_set_field
    :expense_item_id
  end

  def to_s
    ret = expense_item.to_s
    ret += " (locked)" if self.locked
    ret
  end

  def custom_cost_present
    if !expense_item.nil? && expense_item.has_custom_cost?
      if self.custom_cost_cents.nil? || self.custom_cost_cents <= 0
        errors[:base] << "Must specify a custom cost for this item"
      end
    end
  end

  def cost
    return 0 if free
    return custom_cost if expense_item.has_custom_cost?

    expense_item.cost
  end

  def tax
    return 0 if free

    expense_item.tax
  end

  def total_cost
    (cost + tax).round(2)
  end

  def only_one_free_per_expense_group
    return true if expense_item_id.nil? || registrant.nil? || (free == false)

    eg = expense_item.expense_group
    if registrant.competitor
      free_options = eg.competitor_free_options
    else
      free_options = eg.noncompetitor_free_options
    end

    case free_options
    when "One Free In Group", "One Free In Group REQUIRED"
      if registrant.has_chosen_free_item_from_expense_group(eg)
        errors[:base] = "Only 1 free item is permitted in this expense_group"
      end
    when "One Free of Each In Group"
      if registrant.has_chosen_free_item_of_expense_item(expense_item)
        errors[:base] = "Only 1 free item of this item is permitted"
      end
    end
    true
  end

  def no_more_than_max_per_registrant
    return true if expense_item_id.nil? || registrant.nil?
    max = expense_item.maximum_per_registrant
    return true if max == 0

    if registrant.all_expense_items.count(expense_item) == max
      errors[:base] = "Each Registrant is only permitted #{max} of #{expense_item}"
    end
  end
end
