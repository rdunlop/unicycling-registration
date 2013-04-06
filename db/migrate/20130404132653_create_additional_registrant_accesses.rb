class CreateAdditionalRegistrantAccesses < ActiveRecord::Migration
  def change
    create_table :additional_registrant_accesses do |t|
      t.integer :user_id
      t.integer :registrant_id
      t.boolean :declined
      t.boolean :accepted_readonly

      t.timestamps
    end
  end
end
