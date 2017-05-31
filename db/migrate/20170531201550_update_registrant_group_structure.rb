class UpdateRegistrantGroupStructure < ActiveRecord::Migration[5.0]
  def up
    # We are not using the existing tables, and we are re-purposing them now
    execute "DELETE FROM registrant_groups"
    execute "DELETE FROM registrant_group_members"

    add_column :registrant_groups, :registrant_group_type_id, :integer
    add_index :registrant_groups, :registrant_group_type_id

    create_table :registrant_group_types do |t|
      t.string :source_element_type, null: false
      t.integer :source_element_id, null: false
      t.string :notes
      t.integer :max_members_per_group
      t.timestamps
    end

    add_column :registrant_group_members, :additional_details_type, :string
    add_column :registrant_group_members, :additional_details_id, :integer
  end

  def down
    remove_column :registrant_groups, :registrant_group_type_id

    drop_table :registrant_group_types

    remove_column :registrant_group_members, :additional_details_type
    remove_column :registrant_group_members, :additional_details_id
  end
end
