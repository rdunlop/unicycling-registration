class AddHeatToCompetitor < ActiveRecord::Migration[4.2]
  def change
    add_column :competitors, :heat, :integer
  end
end
