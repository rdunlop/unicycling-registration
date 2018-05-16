class AddWheelSizeOverrideTable < ActiveRecord::Migration[4.2]
  def change
    create_table :competition_wheel_sizes do |t|
      t.references :registrant
      t.references :event
      t.references :wheel_size
      t.timestamps
    end
  end
end
