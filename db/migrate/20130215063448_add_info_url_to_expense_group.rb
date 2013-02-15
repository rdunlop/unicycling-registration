class AddInfoUrlToExpenseGroup < ActiveRecord::Migration
  def change
    add_column :expense_groups, :info_url, :string
  end
end
