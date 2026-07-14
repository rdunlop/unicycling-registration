class AddCustomLabels < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_label_types do |t|
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
      t.integer :created_by_id, null: false
      t.string :description
      t.timestamps
    end
  end
end
