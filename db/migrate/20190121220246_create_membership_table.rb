class CreateMembershipTable < ActiveRecord::Migration[5.1]
  def change
    create_table :organization_memberships do |t|
      t.references :registrant
      t.string :manual_member_number
      t.string :system_member_number
      t.boolean :manually_confirmed, default: false, null: false
      t.boolean :system_confirmed, default: false, null: false
      t.string :system_status
      t.timestamps null: false
    end
  end
end
