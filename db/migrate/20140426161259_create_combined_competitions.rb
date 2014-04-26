class CreateCombinedCompetitions < ActiveRecord::Migration
  def change
    create_table :combined_competitions do |t|
      t.string :name

      t.timestamps
    end
  end
end
