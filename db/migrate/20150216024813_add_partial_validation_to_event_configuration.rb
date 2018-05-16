class AddPartialValidationToEventConfiguration < ActiveRecord::Migration[4.2]
  def up
    add_column :event_configurations, :validations_applied, :integer

    execute "UPDATE event_configurations SET validations_applied = -1" # default
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
