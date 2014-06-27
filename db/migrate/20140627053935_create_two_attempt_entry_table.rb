class CreateTwoAttemptEntryTable < ActiveRecord::Migration
  def change
    create_table :two_attempt_entries do |t|
      t.references :user
      t.references :competition
      t.integer :bib_number

      t.integer :minutes_1
      t.integer :minutes_2
      t.integer :seconds_1
      t.string :status_1

      t.integer :seconds_2
      t.integer :thousands_1
      t.integer :thousands_2
      t.string :status_2

      t.boolean :is_start_time, default: false

      t.timestamps
    end
  end
end
