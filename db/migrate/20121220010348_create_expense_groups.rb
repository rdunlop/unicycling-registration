class CreateExpenseGroups < ActiveRecord::Migration
  def change
    create_table :expense_groups do |t|
      t.string :group_name
      t.boolean :visible
      t.integer :position

      t.timestamps
    end
  end
end
