class AddPageForCategoryInfo < ActiveRecord::Migration
  def change
    add_column :categories, :info_page_id, :integer
  end
end
