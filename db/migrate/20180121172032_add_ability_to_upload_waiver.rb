class AddAbilityToUploadWaiver < ActiveRecord::Migration[5.1]
  def up
    execute "UPDATE event_configurations SET waiver = 'none' WHERE waiver = 'print'"
    add_column :event_configurations, :waiver_file_name, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
