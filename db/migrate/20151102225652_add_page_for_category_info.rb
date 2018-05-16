class AddPageForCategoryInfo < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :info_page_id, :integer
  end
end
