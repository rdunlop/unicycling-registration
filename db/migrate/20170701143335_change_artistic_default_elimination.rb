class ChangeArtisticDefaultElimination < ActiveRecord::Migration[5.0]
  def up
    change_column_default :event_configurations, :artistic_score_elimination_mode_naucc, false
  end

  def down
    change_column_default :event_configurations, :artistic_score_elimination_mode_naucc, true
  end
end
