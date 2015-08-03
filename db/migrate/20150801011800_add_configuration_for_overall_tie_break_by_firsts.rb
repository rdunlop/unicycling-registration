class AddConfigurationForOverallTieBreakByFirsts < ActiveRecord::Migration
  def change
    add_column :combined_competitions, :tie_break_by_firsts, :boolean, default: true, null: false
  end
end
