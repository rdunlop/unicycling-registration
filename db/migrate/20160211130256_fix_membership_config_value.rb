class FixMembershipConfigValue < ActiveRecord::Migration
  def up
    execute "UPDATE event_configurations SET organization_membership_type = 'usa' WHERE organization_membership_type = 'USA'"
  end

  def down
    execute "UPDATE event_configurations SET organization_membership_type = 'USA' WHERE organization_membership_type = 'usa'"
  end
end
