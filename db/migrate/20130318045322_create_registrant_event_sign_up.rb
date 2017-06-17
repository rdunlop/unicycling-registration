class CreateRegistrantEventSignUp < ActiveRecord::Migration
  # for creating the necessary Event info
  class EventCategory < ActiveRecord::Base
  end

  class Event < ActiveRecord::Base
    has_many :event_categories
  end

  def up
    # Ensure every event has at least one category

    Event.reset_column_information
    EventCategory.reset_column_information

    Event.all.each do |ev|
      if ev.event_categories.count.zero?
        EventCategory.create! event_id: ev.id, position: 1, name: "All"
      end
    end

    create_table :registrant_event_sign_ups do |t|
      t.integer :registrant_id
      t.boolean :signed_up
      t.integer :event_category_id
      t.timestamps
    end
  end

  def down
    remove_table :registrant_event_sign_ups
  end
end
