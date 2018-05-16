class AddRequiredIfToEventChoice < ActiveRecord::Migration[4.2]
  def change
    add_column :event_choices, :required_if_event_choice_id, :integer
  end
end
