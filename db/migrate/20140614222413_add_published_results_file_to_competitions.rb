class AddPublishedResultsFileToCompetitions < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :published_results_file, :string
  end
end
