class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.string :name
      t.integer :category_id
      t.string :description
      t.integer :position

      t.timestamps
    end
  end
end
