class CreateRegistrantGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :registrant_groups do |t|
      t.string :name
      t.integer :registrant_id

      t.timestamps
    end
  end
end
