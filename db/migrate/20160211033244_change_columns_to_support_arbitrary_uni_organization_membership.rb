class ChangeColumnsToSupportArbitraryUniOrganizationMembership < ActiveRecord::Migration
  def up
    rename_column :event_configurations, :usa_membership_config, :organization_membership_config
    add_column :event_configurations, :organization_membership_type, :string

    execute "UPDATE event_configurations SET organization_membership_type = 'USA' WHERE organization_membership_config"

    rename_column :contact_details, :usa_member_number, :organization_member_number
    rename_column :contact_details, :usa_confirmed_paid, :organization_membership_manually_confirmed
    rename_column :contact_details, :usa_member_number_valid, :organization_membership_system_confirmed

    remove_column :event_configurations, :usa_individual_expense_item_id
    remove_column :event_configurations, :usa_family_expense_item_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
