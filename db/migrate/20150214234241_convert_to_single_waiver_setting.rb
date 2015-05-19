class ConvertToSingleWaiverSetting < ActiveRecord::Migration
  def up
    add_column :event_configurations, :waiver, :string, default: "none"

    execute "UPDATE event_configurations SET waiver = 'none'" # default
    execute "UPDATE event_configurations SET waiver = 'online' WHERE has_online_waiver = true"
    execute "UPDATE event_configurations SET waiver = 'print' WHERE has_print_waiver = true"

    remove_column :event_configurations, :has_online_waiver
    remove_column :event_configurations, :has_print_waiver
  end

  def down
    add_column :event_configurations, :has_online_waiver, :boolean
    add_column :event_configurations, :has_print_waiver, :boolean

    execute "UPDATE event_configurations SET has_online_waiver = true WHERE waiver='online'"
    execute "UPDATE event_configurations SET has_print_waiver = true WHERE waiver='print'"

    remove_column :event_configurations, :waiver
  end
end
