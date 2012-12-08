class CreateRegistrantExpenseItems < ActiveRecord::Migration
  def change
    create_table :registrant_expense_items do |t|
      t.integer :registrant_id
      t.integer :expense_item_id

      t.timestamps
    end
  end
end
