class AddPartialValidationToEventConfiguration < ActiveRecord::Migration
  def change
    add_column :event_configurations, :validations_applied, :integer

    execute "UPDATE event_configurations SET validations_applied = -1" # default
  end
end
