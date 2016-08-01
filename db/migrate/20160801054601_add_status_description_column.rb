class AddStatusDescriptionColumn < ActiveRecord::Migration
  def change
    add_column :time_results, :status_description, :string
  end
end
