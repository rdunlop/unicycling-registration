class CreateRegistrantGroupMemberTable < ActiveRecord::Migration
  def change
    create_table :registrant_group_members do |t|
      t.integer :registrant_id
      t.integer :registrant_group_id
      t.timestamps
    end

    add_index :registrant_group_members, ["registrant_group_id"], name: "index_registrant_group_mumbers_registrant_group_id"
    add_index :registrant_group_members, ["registrant_id"], name: "index_registrant_group_mumbers_registrant_id"
    add_index :registrant_groups, ["registrant_id"], name: "index_registrant_groups_registrant_id"
  end
end
