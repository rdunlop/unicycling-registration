class AddAutomaticCompetitorCreation < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :automatic_competitor_creation, :boolean, default: false
  end
end
