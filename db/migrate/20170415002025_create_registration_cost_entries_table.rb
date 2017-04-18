class CreateRegistrationCostEntriesTable < ActiveRecord::Migration[5.0]
  class RegistrationCost < ActiveRecord::Base
  end

  class RegistrationCostEntry < ActiveRecord::Base
  end

  def up
    create_table :registration_cost_entries do |t|
      t.integer :registration_cost_id, index: true, null: false
      t.integer :expense_item_id, null: false
      t.integer :min_age
      t.integer :max_age
      t.timestamps null: false
    end

    RegistrationCostEntry.reset_column_information
    RegistrationCost.all.each do |registration_cost|
      RegistrationCostEntry.create!(
        registration_cost_id: registration_cost.id,
        expense_item_id: registration_cost.expense_item_id,
        created_at: registration_cost.created_at,
        updated_at: registration_cost.updated_at
      )
    end

    remove_column :registration_costs, :expense_item_id
  end

  def down
    add_column :registration_costs, :expense_item_id, :integer
    RegistrationCost.reset_column_information
    RegistrationCostEntry.all.each do |registration_cost_entry|
      rc = RegistrationCost.find(registration_cost_entry.registration_cost_id)
      rc.update(expense_item_id: registration_cost_entry.expense_item_id)
    end

    drop_table :registration_cost_entries
  end
end
