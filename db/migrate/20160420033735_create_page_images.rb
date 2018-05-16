class CreatePageImages < ActiveRecord::Migration[4.2]
  def change
    create_table :page_images do |t|
      t.integer :page_id, null: false
      t.string :name, null: false
      t.string :image, null: false
      t.timestamps null: false
    end
  end
end
