class SplitJudgingFromDataEntryInCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :start_data_type, :string
    add_column :competitions, :end_data_type, :string
  end
end
