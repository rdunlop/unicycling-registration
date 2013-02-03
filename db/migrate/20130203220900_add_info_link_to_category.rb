class AddInfoLinkToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :info_url, :string
  end
end
