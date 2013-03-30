class CreateTimeResults < ActiveRecord::Migration
  def change
    create_table :time_results do |t|
      t.references :event_category
      t.integer :minutes
      t.integer :seconds
      t.integer :thousands
      t.boolean :disqualified
      t.integer :registrant_id

      t.timestamps
    end
    add_index :time_results, :event_category_id
  end
end
