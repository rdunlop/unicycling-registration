class AddCombinedCompetitionToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :combined_competition_id, :integer
  end
end
