class AddPageModel < ActiveRecord::Migration
  class Page < ActiveRecord::Base
    translates :title, :body
  end

  def up
    create_table :pages do |t|
      t.string :slug, null: false
      t.timestamps
    end
    add_index :pages, :slug, unique: true
    Page.reset_column_information
    Page.create_translation_table!({title: :string, body: :text}, {migrate_data: false})
  end

  def down
    Page.drop_translation_table!(migrate_data: false)
    drop_table :pages
  end
end
