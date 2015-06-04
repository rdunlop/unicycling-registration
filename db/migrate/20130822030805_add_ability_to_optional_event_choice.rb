class AddAbilityToOptionalEventChoice < ActiveRecord::Migration
  def change
    add_column :event_choices, :optional, :boolean, default: false
  end
end
