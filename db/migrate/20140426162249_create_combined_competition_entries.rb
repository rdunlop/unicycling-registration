class CreateCombinedCompetitionEntries < ActiveRecord::Migration
  def change
    create_table :combined_competition_entries do |t|
      t.integer :combined_competition_id
      t.string :abbreviation
      t.boolean :tie_breaker
      t.integer :points_1
      t.integer :points_2
      t.integer :points_3
      t.integer :points_4
      t.integer :points_5
      t.integer :points_6
      t.integer :points_7
      t.integer :points_8
      t.integer :points_9
      t.integer :points_10

      t.timestamps
    end
  end
end
