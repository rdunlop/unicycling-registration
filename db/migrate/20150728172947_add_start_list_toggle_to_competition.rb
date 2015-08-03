class AddStartListToggleToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :sign_in_list_enabled, :boolean, null: false, default: false
  end
end
