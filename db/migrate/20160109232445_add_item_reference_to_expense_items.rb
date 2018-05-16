class AddItemReferenceToExpenseItems < ActiveRecord::Migration[4.2]
  def change
    add_reference :expense_items, :cost_element, polymorphic: true, index: true
  end
end
