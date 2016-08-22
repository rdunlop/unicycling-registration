class CreateMassEmailModel < ActiveRecord::Migration
  def change
    create_table :mass_emails do |t|
      t.integer :sent_by_id, null: false
      t.datetime :sent_at
      t.string :subject
      t.text :body
      t.text :email_addresses, array: true
      t.string :email_addresses_description
      t.timestamps null: false
    end
    add_index :mass_emails, :email_addresses, using: 'gin'
  end
end
