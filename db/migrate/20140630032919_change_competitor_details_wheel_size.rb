class ChangeCompetitorDetailsWheelSize < ActiveRecord::Migration[4.2]
  def change
    rename_column :competitors, :wheel_size, :riding_wheel_size
  end
end
