class PopulateRegistrantEventSignUp < ActiveRecord::Migration
  # for updating the registrant data
  class EventCategory < ActiveRecord::Base
  end

  class EventChoice < ActiveRecord::Base
  end

  class RegistrantChoice < ActiveRecord::Base
  end

  class RegistrantEventSignUp < ActiveRecord::Base
  end

  def up
    # Associate all existing choices with the new table
    RegistrantEventSignUp.reset_column_information
    EventCategory.reset_column_information
    EventChoice.reset_column_information
    RegistrantChoice.reset_column_information

    # For each primary choice
    EventChoice.where({position: 1}).each do |ec|
      # find all registrants who have chosen this
      RegistrantChoice.where({event_choice_id: ec.id}).each do |rc|
        next if rc.value == "0"
        # determine the event_category for this user
        category_ec = EventChoice.where({cell_type: "category", event_id: ec.event_id}).first
        category_id = nil
        unless category_ec.nil?
          reg_category_choice = RegistrantChoice.where({event_choice_id: category_ec.id, registrant_id: rc.registrant_id}).first
          category_id = reg_category_choice.event_category_id unless reg_category_choice.nil?
        end
        if category_id.nil?
          category_id = EventCategory.where({event_id: ec.event_id}).first.id
        end

        RegistrantEventSignUp.create! registrant_id: rc.registrant_id, signed_up: true, event_category_id: category_id
      end
    end
  end

  def down
  end
end
