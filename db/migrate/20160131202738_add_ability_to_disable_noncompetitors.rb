class AddAbilityToDisableNoncompetitors < ActiveRecord::Migration
  def change
    add_column :event_configurations, :noncompetitors, :boolean, default: true, null: false
  end
end
