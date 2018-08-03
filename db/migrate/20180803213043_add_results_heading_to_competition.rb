class AddResultsHeadingToCompetition < ActiveRecord::Migration[5.1]
  def change
    add_column :competitions, :results_header, :string
  end
end
