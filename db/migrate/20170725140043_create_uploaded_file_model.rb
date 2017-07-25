class CreateUploadedFileModel < ActiveRecord::Migration[5.0]
  def change
    create_table :uploaded_files do |t|
      t.integer :competition_id, index: true, null: false
      t.integer :user_id, index: true, null: false
      t.string :filename, null: false
      t.string :file, null: false
      t.timestamps
    end
  end
end
