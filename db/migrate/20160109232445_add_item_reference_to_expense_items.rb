class AddItemReferenceToExpenseItems < ActiveRecord::Migration
  def change
    add_reference :expense_items, :cost_element, polymorphic: true, index: true
  end
end
