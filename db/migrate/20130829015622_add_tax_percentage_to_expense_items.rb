class AddTaxPercentageToExpenseItems < ActiveRecord::Migration
  def change
    add_column :expense_items, :tax_percentage, :integer, :default => 0
  end
end
