class RenameUsaMemberStatus < ActiveRecord::Migration[4.2]
  def change
    rename_column :contact_details, :usa_member_number_status, :organization_membership_system_status
  end
end
