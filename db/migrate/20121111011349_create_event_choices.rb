class CreateEventChoices < ActiveRecord::Migration
  def change
    create_table :event_choices do |t|
      t.integer :event_id
      t.string :export_name
      t.string :cell_type
      t.string :multiple_values
      t.string :label
      t.integer :position

      t.timestamps
    end
  end
end
