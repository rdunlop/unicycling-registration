# == Schema Information
#
# Table name: registrant_expense_items
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  line_item_id      :integer
#  created_at        :datetime
#  updated_at        :datetime
#  details           :string(255)
#  free              :boolean          default(FALSE), not null
#  system_managed    :boolean          default(FALSE), not null
#  locked            :boolean          default(FALSE), not null
#  custom_cost_cents :integer
#  line_item_type    :string
#
# Indexes
#
#  index_registrant_expense_items_registrant_id  (registrant_id)
#  registrant_expense_items_line_item            (line_item_id,line_item_type)
#

class RegistrantExpenseItem < ApplicationRecord
  include CachedSetModel
  include CachedModel
  include HasDetailsDescription

  belongs_to :registrant, touch: true
  belongs_to :line_item, polymorphic: true, inverse_of: :registrant_expense_items

  has_paper_trail meta: { registrant_id: :registrant_id }

  validates :line_item, :registrant, presence: true
  validate :only_one_free_per_expense_group, on: :create
  validate :no_more_than_max_per_registrant, on: :create
  validate :custom_cost_present

  monetize :custom_cost_cents, allow_nil: true

  delegate :has_details?, :details_label, to: :line_item

  def self.system_managed
    where(system_managed: true)
  end

  def self.free
    where(free: true)
  end

  def self.cache_set_field
    :line_item_id # XXX????
  end

  def to_s
    ret = line_item.to_s
    ret += " (locked)" if locked
    ret
  end

  def cost
    return 0 if free
    return custom_cost if line_item.has_custom_cost?

    line_item.cost
  end

  def tax
    return 0 if free

    line_item.tax
  end

  def total_cost
    (cost + tax).round(2)
  end

  private

  def only_one_free_per_expense_group
    return true if line_item_id.nil? || registrant.nil? || (free == false)

    if line_item_type == "ExpenseItem" # should be extract out
      free_item_checker = ExpenseItemFreeChecker.new(registrant, line_item)
      if free_item_checker.free_item_already_exists?
        errors.add(:base, free_item_checker.error_message)
      end
    end
  end

  def no_more_than_max_per_registrant
    return true if line_item_id.nil? || registrant.nil?
    if line_item_type == "ExpenseItem" # should be extracted out
      max = line_item.maximum_per_registrant.to_i
      return true if max.zero?

      if registrant.all_expense_items.count(line_item) == max
        errors.add(:base, "Each Registrant is only permitted #{max} of #{line_item}")
      end
    end
  end

  def custom_cost_present
    if !line_item.nil? && line_item.has_custom_cost?
      if custom_cost_cents.nil? || custom_cost_cents <= 0
        errors.add(:base, "Must specify a custom cost for this item")
      end
    end
  end
end
