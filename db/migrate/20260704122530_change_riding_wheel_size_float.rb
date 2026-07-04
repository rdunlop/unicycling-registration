class ChangeRidingWheelSizeFloat < ActiveRecord::Migration[8.1]
  def up
    change_column :competitors, :riding_wheel_size, :float
  end
  def down
    change_column :competitors, :riding_wheel_size, :integer
  end
end
