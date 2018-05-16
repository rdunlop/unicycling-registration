class ChangeNullOnExpenseGroupBooleans < ActiveRecord::Migration[4.2]
  def change
    change_column :expense_groups, :competitor_required, :boolean, default: false, null: false
    change_column :expense_groups, :noncompetitor_required, :boolean, default: false, null: false
    change_column :expense_groups, :visible, :boolean, default: true, null: false
  end
end
