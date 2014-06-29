class AddOverallDistanceCalculation < ActiveRecord::Migration
  def change
    add_column :combined_competitions, :use_age_group_places, :boolean, default: false
    add_column :combined_competitions, :percentage_based_calculations, :boolean, default: false
  end
end
