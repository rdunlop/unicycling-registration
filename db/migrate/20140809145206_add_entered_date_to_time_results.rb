class AddEnteredDateToTimeResults < ActiveRecord::Migration
  def change
    add_column :time_results, :entered_at, :datetime
  end
end
