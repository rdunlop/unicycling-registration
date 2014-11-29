class AllowWheelSizeOptions < ActiveRecord::Migration
  def change
    add_column :events, :accepts_wheel_size_override, :boolean, default: false

    add_index :events, :accepts_wheel_size_override
  end
end
