class AllowCompetitionToHaveDifferentDataEntryColumns < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :time_entry_columns, :string, default: "minutes_seconds_thousands"
  end
end
