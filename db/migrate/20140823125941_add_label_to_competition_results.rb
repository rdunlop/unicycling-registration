class AddLabelToCompetitionResults < ActiveRecord::Migration[4.2]
  def change
    add_column :competition_results, :name, :string
  end
end
