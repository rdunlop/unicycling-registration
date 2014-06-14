class AddPublishedToCompetitions < ActiveRecord::Migration
  def change
    add_column :competitions, :published, :boolean, default: false
  end
end
