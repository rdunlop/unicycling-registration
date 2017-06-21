class ExpenseItemFreeChecker
  attr_reader :registrant, :expense_item, :error_message
  delegate :paid_details, :registrant_expense_items, :registrant_type_model, to: :registrant

  def initialize(registrant, expense_item)
    @registrant = registrant
    @expense_item = expense_item
  end

  def expense_item_is_free?
    free_options = registrant_type_model.free_options(expense_item.expense_group, registrant)

    case free_options
    when "One Free In Group", "One Free In Group REQUIRED"
      return !chosen_free_item_from_expense_group?(expense_item.expense_group)
    when "One Free of Each In Group"
      return !chosen_free_item_of_expense_item?(expense_item)
    else
      return false
    end
  end

  # Return true on failure, and set :error_message
  def free_item_already_exists?
    free_options = registrant_type_model.free_options(expense_item.expense_group, registrant)

    case free_options
    when "One Free In Group", "One Free In Group REQUIRED"
      if chosen_free_item_from_expense_group?(expense_item.expense_group)
        @error_message = "Only 1 free item is permitted in this expense_group"
        return true
      end
    when "One Free of Each In Group"
      if chosen_free_item_of_expense_item?(expense_item)
        @error_message = "Only 1 free item of this item is permitted"
        return true
      end
    end

    false
  end

  private

  # return true if user has chosen or paid for an expense item
  # given a block which defines what we are comparing to
  def chosen_free_item?
    registrant_expense_items.each do |rei|
      next unless rei.free
      if yield(rei.expense_item)
        return true
      end
    end

    paid_details.each do |pei|
      next unless pei.free
      if yield(pei.expense_item)
        return true
      end
    end

    false
  end

  # return true/false to show whether an expense_group has been chosen by this registrant
  def chosen_free_item_from_expense_group?(expense_group)
    chosen_free_item?{ |expense_item| expense_item.expense_group == expense_group }
  end

  def chosen_free_item_of_expense_item?(target_expense_item)
    chosen_free_item?{ |expense_item| expense_item == target_expense_item }
  end
end
