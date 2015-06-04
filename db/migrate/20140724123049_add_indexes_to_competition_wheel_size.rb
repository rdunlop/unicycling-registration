class AddIndexesToCompetitionWheelSize < ActiveRecord::Migration
  def change
    add_index "competition_wheel_sizes", ["registrant_id", "event_id"], name: "index_competition_wheel_sizes_registrant_id_event_id"
  end
end
