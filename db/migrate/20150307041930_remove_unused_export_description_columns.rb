class RemoveUnusedExportDescriptionColumns < ActiveRecord::Migration
  def change
    remove_column :event_choices, :export_name, :string
    remove_column :events, :export_name, :string
    remove_column :expense_items, :export_name, :string
    remove_column :expense_items, :description, :string
    remove_column :expense_item_translations, :description, :string
  end
end
