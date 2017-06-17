class FixVolunteerOptionValue < ActiveRecord::Migration
  def up
    execute "UPDATE event_configurations SET volunteer_option = 'choice' WHERE volunteer_option = 'choices'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
