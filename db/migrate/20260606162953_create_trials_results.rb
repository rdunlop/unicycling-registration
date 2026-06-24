class CreateTrialsResults < ActiveRecord::Migration[8.1]
  def change
    create_table :trials_results do |t|
      t.integer :competitor_id, null: false
      t.integer :points, null: false
      t.integer :minutes, null: false
      t.integer :seconds, null: false
      t.string :details
      t.datetime :entered_at, null: false
      t.integer :entered_by_id, null: false
      t.string :status, null: false

      t.timestamps
    end

    add_index :trials_results, :competitor_id, unique: true
  end
end
