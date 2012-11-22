class CreateRegistrationPeriods < ActiveRecord::Migration
  def change
    create_table :registration_periods do |t|
      t.date :start_date
      t.date :end_date
      t.integer :competitor_cost
      t.integer :noncompetitor_cost
      t.string :name

      t.timestamps
    end
  end
end
