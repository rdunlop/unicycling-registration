class AddOptionalIfToEventChoice < ActiveRecord::Migration
  def change
    add_column :event_choices, :optional_if_event_choice_id, :integer
  end
end
