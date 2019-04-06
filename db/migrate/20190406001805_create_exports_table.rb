class CreateExportsTable < ActiveRecord::Migration[5.1]
  def change
    create_table :exports do |t|
      t.string :export_type, null: false
      t.integer :exported_by_id, null: false, index: true
      t.string :file
      t.timestamps
    end
  end
end
