class AddAutomaticCompetitorCreation < ActiveRecord::Migration
  def change
    add_column :competitions, :automatic_competitor_creation, :boolean, default: false
  end
end
