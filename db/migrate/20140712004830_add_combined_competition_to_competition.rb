class AddCombinedCompetitionToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :combined_competition_id, :integer
  end
end
