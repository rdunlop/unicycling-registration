class EventForm < SimpleDelegator
  attr_accessor :cost

  def valid?
    super
  end

  def assign_attributes(attributes = {})
    @cost = attributes.delete(:cost)
    super
  end

  def save
    transaction do
      if cost.present?
        if expense_item.nil?
          # need to create a new expense_item
          build_necessary_expense_item
        else
          # expense_item already exists, destroy it and create a new
          unless expense_item.cost == cost
            expense_item.destroy
            build_necessary_expense_item
          end
        end
      else
        if expense_item.present?
          # destroy it
          expense_item.destroy
        end
      end

      super
    end
  end

  private

  def build_necessary_expense_item
    expense_group = ExpenseGroup.event_items_group
    build_expense_item(
      expense_group: expense_group,
      name: "#{name} - #{cost}",
      position: (expense_group.expense_items.maximum(:position) || 0) + 1,
      cost: cost
    )
  end
end
