class AddMusicCutoffDate < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :music_submission_end_date, :date
  end
end
