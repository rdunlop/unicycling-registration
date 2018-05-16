class AddCounterForEventChoices < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :event_choices_count, :integer, null: false, default: 0
  end
end
