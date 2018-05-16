class AddStatusDescriptionColumn < ActiveRecord::Migration[4.2]
  def change
    add_column :time_results, :status_description, :string
  end
end
