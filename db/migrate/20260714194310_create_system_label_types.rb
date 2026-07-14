class CreateSystemLabelTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :system_label_types do |t|
      t.string :name, null: false
      t.string :paper_size, null: false
      t.string :paper_size_custom
      t.integer :columns, null: false
      t.integer :rows, null: false
      t.float :top_margin, null: false
      t.float :bottom_margin, null: false
      t.float :left_margin, null: false
      t.float :right_margin, null: false
      t.float :column_gutter, null: false
      t.float :row_gutter, null: false
      t.string :description

      t.timestamps
    end
    add_index :system_label_types, :name, unique: true
  end
end
