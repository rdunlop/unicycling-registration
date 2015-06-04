class AddMissingIndexesOnContactDetail < ActiveRecord::Migration
  def change
    add_index "contact_details", ["registrant_id"], name: "index_contact_details_registrant_id"
    add_index "songs", ["registrant_id"], name: "index_songs_registrant_id"
  end
end
