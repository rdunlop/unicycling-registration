class ChangeCompetitorDetailsWheelSize < ActiveRecord::Migration
  def change
    rename_column :competitors, :wheel_size, :riding_wheel_size
  end
end
