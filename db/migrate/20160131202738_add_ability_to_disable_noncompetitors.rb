class AddAbilityToDisableNoncompetitors < ActiveRecord::Migration[4.2]
  def change
    add_column :event_configurations, :noncompetitors, :boolean, default: true, null: false
  end
end
