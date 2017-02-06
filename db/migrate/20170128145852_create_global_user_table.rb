class CreateGlobalUserTable < ActiveRecord::Migration[5.0]
  def change
    create_table :user_conventions do |t|
      t.integer :user_id, null: false # global_user_id
      t.integer :legacy_user_id # user_id
      t.string :subdomain, null: false
      t.string :legacy_encrypted_password, limit: 255
      t.timestamps
    end
  end
end
