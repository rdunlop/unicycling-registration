class AddLabelToCompetitionResults < ActiveRecord::Migration
  def change
    add_column :competition_results, :name, :string
  end
end
