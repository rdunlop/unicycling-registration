class CreateReportsTable < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :report_type, null: false
      t.string :url
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
