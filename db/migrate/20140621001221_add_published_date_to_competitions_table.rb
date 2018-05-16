class AddPublishedDateToCompetitionsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :published_date, :datetime
  end
end
