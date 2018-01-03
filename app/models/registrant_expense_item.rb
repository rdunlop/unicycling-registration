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
  validate :can_add_another_of_this_line_item?, on: :create
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
    :line_item_type_and_id
  end

  def line_item_type_and_id
    [line_item_type, line_item_id].join("/")
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

  def can_add_another_of_this_line_item?
    return true if line_item_id.nil? || registrant.nil?

    returned_errors = line_item.can_create_registrant_expense_item?(self)
    returned_errors.each do |error|
      errors.add(:base, error)
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
