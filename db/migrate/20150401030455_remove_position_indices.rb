class RemovePositionIndices < ActiveRecord::Migration
  def up
    remove_index :event_categories, name: 'index_event_categories_on_event_id_and_position'
    remove_index :event_choices, %i[event_id position]
  end

  def down
    add_index :event_categories, %i[event_id position], unique: true, name: 'index_event_categories_on_event_id_and_position'
    add_index :event_choices, %i[event_id position], unique: true
  end
end
