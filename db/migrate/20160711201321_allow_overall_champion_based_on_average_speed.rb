class AllowOverallChampionBasedOnAverageSpeed < ActiveRecord::Migration
  def up
    add_column :combined_competitions, :calculation_mode, :string
    execute "UPDATE combined_competitions SET calculation_mode = 'default'"
    execute "UPDATE combined_competitions SET calculation_mode = 'percentage' WHERE percentage_based_calculations = TRUE"
    change_column_null :combined_competitions, :calculation_mode, false
    remove_column :combined_competitions, :percentage_based_calculations
    add_column :combined_competition_entries, :distance, :integer
  end

  def down
    add_column :combined_competitions, :percentage_based_calculations, :boolean, default: false, null: false
    execute "UPDATE combined_competitions SET percentage_based_calculations = TRUE WHERE calculation_mode = 'percentage'"
    remove_column :combined_competitions, :calculation_mode
    remove_column :combined_competition_entries, :distance
  end
end
