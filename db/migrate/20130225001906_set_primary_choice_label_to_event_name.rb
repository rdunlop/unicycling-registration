class SetPrimaryChoiceLabelToEventName < ActiveRecord::Migration
  class EventChoice < ActiveRecord::Base
  end
  class Event < ActiveRecord::Base
  end

  def up
    EventChoice.reset_column_information
    Event.reset_column_information
    EventChoice.where({:position => 1}).each do |ec|
      ev = Event.find(ec.event_id)
      ec.label = ev.name
      ec.save!
    end
    remove_column :events, :name
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
