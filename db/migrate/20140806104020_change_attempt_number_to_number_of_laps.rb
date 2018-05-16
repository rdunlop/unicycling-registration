class ChangeAttemptNumberToNumberOfLaps < ActiveRecord::Migration[4.2]
  def change
    rename_column :import_results, :attempt_number, :number_of_laps
    rename_column :time_results, :attempt_number, :number_of_laps
  end
end
