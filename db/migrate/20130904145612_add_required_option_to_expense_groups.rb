class AddRequiredOptionToExpenseGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_groups, :competitor_required, :boolean, default: false
    add_column :expense_groups, :noncompetitor_required, :boolean, default: false
  end
end
