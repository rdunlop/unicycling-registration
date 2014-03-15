class AddRequiredIfToEventChoice < ActiveRecord::Migration
  def change
    add_column :event_choices, :required_if_event_choice_id, :integer
  end
end
