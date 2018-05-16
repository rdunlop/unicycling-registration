class AddAbilityToPenalizeTimes < ActiveRecord::Migration[4.2]
  def change
    add_column :import_results, :number_of_penalties, :integer
    add_column :competitions, :penalty_seconds, :integer
    add_column :time_results, :number_of_penalties, :integer
  end
end
