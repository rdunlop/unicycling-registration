class AddStartListToggleToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :sign_in_list_enabled, :boolean, null: false, default: false
  end
end
