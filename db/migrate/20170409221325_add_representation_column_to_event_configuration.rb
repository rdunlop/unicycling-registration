class AddRepresentationColumnToEventConfiguration < ActiveRecord::Migration[5.0]
  def up
    add_column :event_configurations, :representation_type, :string, default: "country", null: false
    execute "UPDATE event_configurations SET representation_type = 'state' WHERE usa = TRUE"
  end

  def down
    remove_column :event_configurations, :representation_type
  end
end
