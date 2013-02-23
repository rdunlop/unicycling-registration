class AddAutocompleteToEventChoice < ActiveRecord::Migration
  def change
    add_column :event_choices, :autocomplete, :boolean
  end
end
