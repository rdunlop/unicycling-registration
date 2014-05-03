class AddCompetitionToCombinedCompetitionEntry < ActiveRecord::Migration
  def change
    add_column :combined_competition_entries, :competition_id, :integer
  end
end
