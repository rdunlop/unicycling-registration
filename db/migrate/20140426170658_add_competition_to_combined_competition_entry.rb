class AddCompetitionToCombinedCompetitionEntry < ActiveRecord::Migration[4.2]
  def change
    add_column :combined_competition_entries, :competition_id, :integer
  end
end
