class CreateMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :members do |t|
      t.integer  "competitor_id"
      t.integer  "registrant_id"
      t.timestamps
    end
  end
end
