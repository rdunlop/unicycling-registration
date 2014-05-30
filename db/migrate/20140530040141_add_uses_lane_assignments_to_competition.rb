class AddUsesLaneAssignmentsToCompetition < ActiveRecord::Migration
  def change
    add_column :competitions, :uses_lane_assignments, :boolean, default: false
  end
end
