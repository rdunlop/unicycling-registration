class AddPublishedDateToCompetitionsTable < ActiveRecord::Migration
  def change
    add_column :competitions, :published_date, :datetime
  end
end
