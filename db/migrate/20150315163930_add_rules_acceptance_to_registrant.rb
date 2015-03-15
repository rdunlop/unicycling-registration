class AddRulesAcceptanceToRegistrant < ActiveRecord::Migration
  def change
    add_column :registrants, :rules_accepted, :boolean, default: false, null: false
    add_column :event_configurations, :rules_file_name, :string, default: nil
    add_column :event_configurations, :accept_rules, :boolean, default: false, null: false
  end
end
