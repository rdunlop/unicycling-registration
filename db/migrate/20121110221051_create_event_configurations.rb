class CreateEventConfigurations < ActiveRecord::Migration
  def change
    create_table :event_configurations do |t|
      t.string :short_name
      t.string :long_name
      t.string :location
      t.string :dates_description
      t.string :event_url
      t.date :start_date
      t.binary :logo
      t.string :currency
      t.string :contact_email
      t.boolean :closed
      t.date :artistic_closed_date
      t.date :standard_skill_closed_date
      t.date :tshirt_closed_date

      t.timestamps
    end
  end
end
