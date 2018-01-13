class AddConventionSeries < ActiveRecord::Migration[5.1]
  def change
    create_table :convention_series do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :convention_series_members do |t|
      t.integer :convention_series_id, null: false, index: true
      t.integer :tenant_id, null: false, index: true
      t.timestamps
    end

    add_index :convention_series_members, %i[tenant_id convention_series_id], unique: true, name: "convention_series_member_ids_unique"
    add_index :convention_series, [:name], unique: true
  end
end
