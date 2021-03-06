class CreateExpenseItems < ActiveRecord::Migration[4.2]
  def change
    create_table :expense_items do |t|
      t.string :name
      t.string :description
      t.decimal :cost
      t.string :export_name
      t.integer :position

      t.timestamps
    end
  end
end
