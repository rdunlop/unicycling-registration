class AddAbilityToOptionalEventChoice < ActiveRecord::Migration[4.2]
  def change
    add_column :event_choices, :optional, :boolean, default: false
  end
end
