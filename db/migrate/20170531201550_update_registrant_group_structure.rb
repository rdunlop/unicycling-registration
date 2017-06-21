class UpdateRegistrantGroupStructure < ActiveRecord::Migration[5.0]
  def up
    # We are not using the existing tables, and we are re-purposing them now
    execute "DELETE FROM registrant_groups"
    execute "DELETE FROM registrant_group_members"

    add_column :registrant_groups, :registrant_group_type_id, :integer
    add_index :registrant_groups, :registrant_group_type_id
    remove_column :registrant_groups, :registrant_id

    create_table :registrant_group_types do |t|
      t.string :source_element_type, null: false
      t.integer :source_element_id, null: false
      t.string :notes
      t.integer :max_members_per_group
      t.timestamps
    end

    create_table :registrant_group_leaders do |t|
      t.integer :registrant_group_id, null: false, index: true
      t.integer :user_id, null: false, index: true
      t.timestamps
    end
    add_index :registrant_group_leaders, %i[registrant_group_id user_id], unique: true, name: "registrant_group_leaders_uniq"

    add_column :registrant_group_members, :additional_details_type, :string
    add_column :registrant_group_members, :additional_details_id, :integer
  end

  def down
    remove_column :registrant_groups, :registrant_group_type_id
    add_column :registrant_groups, :registrant_id, :integer
    add_index :registrant_groups, :registrant_id

    drop_table :registrant_group_types
    drop_table :registrant_group_leaders

    remove_column :registrant_group_members, :additional_details_type
    remove_column :registrant_group_members, :additional_details_id
  end
end
