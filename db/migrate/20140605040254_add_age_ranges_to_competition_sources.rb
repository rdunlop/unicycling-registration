class AddAgeRangesToCompetitionSources < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_sources, :min_age, :integer
    add_column :competition_sources, :max_age, :integer
  end
end
