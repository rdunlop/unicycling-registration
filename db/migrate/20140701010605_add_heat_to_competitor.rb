class AddHeatToCompetitor < ActiveRecord::Migration
  def change
    add_column :competitors, :heat, :integer
  end
end
