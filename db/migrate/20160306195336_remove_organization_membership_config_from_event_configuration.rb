class RemoveOrganizationMembershipConfigFromEventConfiguration < ActiveRecord::Migration
  def up
    remove_column :event_configurations, :organization_membership_config
  end

  def down
    add_column :event_configurations, :organization_membership_config, :boolean, default: false, null: false
    execute "UPDATE event_configurations SET organization_membership_config=TRUE where (organization_membership_type <> '' AND organization_membership_type IS NOT NULL)"
  end
end
