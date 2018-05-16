class AddPublishedToCompetitions < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :published, :boolean, default: false
  end
end
