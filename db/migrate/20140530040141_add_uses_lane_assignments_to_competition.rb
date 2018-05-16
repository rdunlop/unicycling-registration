class AddUsesLaneAssignmentsToCompetition < ActiveRecord::Migration[4.2]
  def change
    add_column :competitions, :uses_lane_assignments, :boolean, default: false
  end
end
