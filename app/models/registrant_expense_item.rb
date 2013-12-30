class RegistrantExpenseItem < ActiveRecord::Base
  belongs_to :registrant
  belongs_to :expense_item, :inverse_of => :registrant_expense_items

  has_paper_trail :meta => { :registrant_id => :registrant_id }

  validates :expense_item, :registrant, :presence => true
  validate :only_one_free_per_expense_group, :on => :create

  delegate :has_details, to: :expense_item
  delegate :details_label, to: :expense_item

  def cost
    return 0 if free

    expense_item.cost
  end

  def tax
    return 0 if free

    expense_item.tax
  end

  def total_cost
    cost + tax
  end

  def only_one_free_per_expense_group
    return true if expense_item_id.nil? or registrant.nil? or (free == false)

    eg = expense_item.expense_group
    if registrant.competitor
      free_options = eg.competitor_free_options
    else
      free_options = eg.noncompetitor_free_options
    end

    case free_options
    when "One Free In Group"
      if registrant.has_chosen_free_item_from_expense_group(eg)
        errors[:base] = "Only 1 free item is permitted in this expense_group"
      end
    when "One Free of Each In Group"
      if registrant.has_chosen_free_item_of_expense_item(expense_item)
        errors[:base] = "Only 1 free item of this item is permitted"
      end
    end
    return true
  end
end
