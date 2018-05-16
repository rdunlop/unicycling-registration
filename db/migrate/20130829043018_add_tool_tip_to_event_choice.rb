class AddToolTipToEventChoice < ActiveRecord::Migration[4.2]
  def change
    add_column :event_choices, :tooltip, :string
  end
end
