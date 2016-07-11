class AllowCompetitionToHaveDifferentDataEntryColumns < ActiveRecord::Migration
  def change
    add_column :competitions, :time_entry_columns, :string, default: "minutes_seconds_thousands"
  end
end
