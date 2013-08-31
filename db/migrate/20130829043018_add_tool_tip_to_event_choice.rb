class AddToolTipToEventChoice < ActiveRecord::Migration
  def change
    add_column :event_choices, :tooltip, :string
  end
end
