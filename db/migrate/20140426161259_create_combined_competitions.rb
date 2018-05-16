class CreateCombinedCompetitions < ActiveRecord::Migration[4.2]
  def change
    create_table :combined_competitions do |t|
      t.string :name

      t.timestamps
    end
  end
end
