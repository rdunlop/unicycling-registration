class RemoveAutocomplete < ActiveRecord::Migration[4.2]
  def change
    remove_column :event_choices, :autocomplete, default: false, null: false
  end
end
