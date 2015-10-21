class AddOrderAndParentsToPages < ActiveRecord::Migration
  def change
    add_column :pages, :position, :integer
    add_column :pages, :parent_page_id, :integer

    add_index :pages, [:position]
    add_index :pages, [:parent_page_id, :position]
  end
end
