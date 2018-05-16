class AddBasePointsToCombinedCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :combined_competition_entries, :base_points, :integer
  end
end
