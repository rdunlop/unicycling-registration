class AddEnteredDateToTimeResults < ActiveRecord::Migration[4.2]
  def change
    add_column :time_results, :entered_at, :datetime
  end
end
