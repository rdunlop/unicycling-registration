class CreateFeedbacksTable < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :user_id
      t.string :entered_email
      t.text :message
      t.string :status, null: false, default: "new"
      t.datetime :resolved_at
      t.integer :resolved_by_id
      t.text :resolution
      t.timestamps null: false
    end
  end
end
