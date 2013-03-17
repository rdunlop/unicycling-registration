class AddEventCategoriesModel < ActiveRecord::Migration
  class EventChoice < ActiveRecord::Base
  end
  class EventCategory < ActiveRecord::Base
    attr_accessible :name, :position, :event_id
  end

  def change
    create_table :event_categories do |t|
      t.integer :event_id
      t.integer :position
      t.string :name
      t.timestamps
    end
    EventCategory.reset_column_information
    EventChoice.reset_column_information
    EventChoice.all.each do |ec|
      if ec.cell_type == 'multiple'
        ec.multiple_values.split(%r{,\s*}).each_with_index do |val, i|
          EventCategory.create :event_id => ec.event_id, :name => val, :position => i + 1
        end
      end
    end
  end
end
