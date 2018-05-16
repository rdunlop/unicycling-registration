class AddOrderAndParentsToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :position, :integer
    add_column :pages, :parent_page_id, :integer

    add_index :pages, [:position]
    add_index :pages, %i[parent_page_id position]
  end
end
