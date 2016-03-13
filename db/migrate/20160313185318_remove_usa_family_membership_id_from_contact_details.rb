class RemoveUsaFamilyMembershipIdFromContactDetails < ActiveRecord::Migration
  def up
    remove_column :contact_details, :usa_family_membership_holder_id
  end

  def down
    add_column :contact_details, :usa_family_membership_holder_id, :integer
  end
end
