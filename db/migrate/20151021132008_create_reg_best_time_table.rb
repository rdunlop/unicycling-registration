class CreateRegBestTimeTable < ActiveRecord::Migration
  def change
    add_column :events, :best_time_format, :string, null: false, default: "none"
    create_table :registrant_best_times do |t|
      t.integer :event_id, null: false
      t.integer :registrant_id, null: false
      t.string :source_location, null: false
      t.integer :value, null: false
      t.timestamps
    end
    add_index :registrant_best_times, %i[event_id registrant_id], unique: true
    add_index :registrant_best_times, [:registrant_id]
  end
end
