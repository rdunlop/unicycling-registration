class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index "event_categories", ["event_id", "position"], name: "index_event_categories_event_id"
    add_index "event_choices", ["event_id", "position"], name: "index_event_choices_event_id"
    add_index "registrant_event_sign_ups", ["registrant_id"], name: "index_registrant_event_sign_ups_registrant_id"
    add_index "registrants", ["deleted"], name: "index_registrants_deleted"
    add_index "registrant_choices", ["registrant_id"], name: "index_registrant_choices_registrant_id"
  end
end
