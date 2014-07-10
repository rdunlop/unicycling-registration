class AddBasePointsToCombinedCompetition < ActiveRecord::Migration
  def change
    add_column :combined_competition_entries, :base_points, :integer
  end
end
