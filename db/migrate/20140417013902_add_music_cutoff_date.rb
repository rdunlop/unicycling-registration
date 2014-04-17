class AddMusicCutoffDate < ActiveRecord::Migration
  def change
    add_column :event_configurations, :music_submission_end_date, :date
  end
end
