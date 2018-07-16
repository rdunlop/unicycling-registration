class CreateEventConfirmationEmails < ActiveRecord::Migration[5.1]
  def change
    create_table :event_confirmation_emails do |t|
      t.integer :sent_by_id
      t.string :reply_to_address
      t.string :subject
      t.text :body
      t.datetime :sent_at
      t.timestamps
    end
  end
end
