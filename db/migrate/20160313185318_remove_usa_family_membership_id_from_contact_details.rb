class RemoveUsaFamilyMembershipIdFromContactDetails < ActiveRecord::Migration[4.2]
  def up
    remove_column :contact_details, :usa_family_membership_holder_id
  end

  def down
    add_column :contact_details, :usa_family_membership_holder_id, :integer
  end
end
