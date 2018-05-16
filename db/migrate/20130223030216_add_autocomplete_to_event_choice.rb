class AddAutocompleteToEventChoice < ActiveRecord::Migration[4.2]
  def change
    add_column :event_choices, :autocomplete, :boolean
  end
end
