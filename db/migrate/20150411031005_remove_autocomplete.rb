class RemoveAutocomplete < ActiveRecord::Migration
  def change
    remove_column :event_choices, :autocomplete, default: false, null: false
  end
end
