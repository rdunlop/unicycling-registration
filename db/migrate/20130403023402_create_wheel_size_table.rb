class CreateWheelSizeTable < ActiveRecord::Migration
  def change
    create_table :wheel_sizes do |t|
      t.integer :position
      t.string :description
      t.timestamps
    end

    add_column :age_group_entries, :wheel_size_id, :integer
    add_column :registrants, :wheel_size_id, :integer
  end
end
