class AddVolunteerChoiceToEventConfiguration < ActiveRecord::Migration
  class VolunteerOpportunity < ActiveRecord::Base
  end

  def up
    add_column :event_configurations, :volunteer_option, :string, default: "generic", null: false
    if VolunteerOpportunity.all.any?
      execute "UPDATE event_configurations SET volunteer_option = 'choices'"
    end
  end

  def down
    remove_column :event_configurations, :volunteer_option
  end
end
