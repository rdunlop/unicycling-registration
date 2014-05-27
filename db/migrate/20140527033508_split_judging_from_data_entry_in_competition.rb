class SplitJudgingFromDataEntryInCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :start_data_type, :string
    add_column :competitions, :end_data_type, :string
  end
end
