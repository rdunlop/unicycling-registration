class PreventDuplicateOrganizationMembership < ActiveRecord::Migration[5.1]
  def change
    remove_index :organization_memberships, [:registrant_id]
    add_index :organization_memberships, [:registrant_id], unique: true
  end
end
