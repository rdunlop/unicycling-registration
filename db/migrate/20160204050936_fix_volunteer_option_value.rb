class FixVolunteerOptionValue < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE event_configurations SET volunteer_option = 'choice' WHERE volunteer_option = 'choices'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
