class ChangeTaxPercentageToDecimalFormat < ActiveRecord::Migration[4.2]
  def change
    change_column :expense_items, :tax_percentage, :decimal, precision: 5, scale: 3
  end
end
