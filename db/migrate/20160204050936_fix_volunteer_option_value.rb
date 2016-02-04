class FixVolunteerOptionValue < ActiveRecord::Migration
  def change
    execute "UPDATE event_configurations SET volunteer_option = 'choice' WHERE volunteer_option = 'choices'"
  end
end
