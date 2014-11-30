class AddCounterForEventChoices < ActiveRecord::Migration
  def change
    add_column :events, :event_choices_count, :integer, null: false, default: 0
  end
end
