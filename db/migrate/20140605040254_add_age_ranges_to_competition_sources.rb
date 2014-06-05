class AddAgeRangesToCompetitionSources < ActiveRecord::Migration
  def change
    add_column :competition_sources, :min_age, :integer
    add_column :competition_sources, :max_age, :integer
  end
end
