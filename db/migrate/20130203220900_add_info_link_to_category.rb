class AddInfoLinkToCategory < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :info_url, :string
  end
end
