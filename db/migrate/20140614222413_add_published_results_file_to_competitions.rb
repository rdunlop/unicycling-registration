class AddPublishedResultsFileToCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :published_results_file, :string
  end
end
