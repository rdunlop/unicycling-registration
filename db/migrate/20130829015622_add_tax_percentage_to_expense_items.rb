class AddTaxPercentageToExpenseItems < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_items, :tax_percentage, :integer, default: 0
  end
end
