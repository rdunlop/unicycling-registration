class AddArtisticScoringTypeToEventConfigurationTable < ActiveRecord::Migration
  def change
    add_column :event_configurations, :artistic_score_elimination_mode_naucc, :boolean, :default => true
  end
end
