class AddNameToEvent < ActiveRecord::Migration
  class EventChoice < ActiveRecord::Base
    belongs_to :event
  end
  class Event < ActiveRecord::Base
  end

  def change
    add_column :events, :name, :string

    Event.reset_column_information
    EventChoice.reset_column_information

    EventChoice.where({:position => 1}).each do |ec|
      ev = ec.event
      ev.name = ec.label
      ev.save!
    end
  end
end
