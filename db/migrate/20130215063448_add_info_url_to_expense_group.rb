class AddInfoUrlToExpenseGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_groups, :info_url, :string
  end
end
