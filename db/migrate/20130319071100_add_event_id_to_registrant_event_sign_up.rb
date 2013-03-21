class AddEventIdToRegistrantEventSignUp < ActiveRecord::Migration
  class RegistrantEventSignUp < ActiveRecord::Base
  end
  class EventCategory < ActiveRecord::Base
  end

  def up
    add_column :registrant_event_sign_ups, :event_id, :integer

    EventCategory.reset_column_information
    RegistrantEventSignUp.reset_column_information
    RegistrantEventSignUp.all.each do |resu|
      resu.event_id = EventCategory.find(resu.event_category_id).event_id
      resu.save!
    end
  end

  def down
    remove_column :registrant_event_sign_ups, :event_id
  end
end
