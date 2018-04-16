class AddEndDateForLodgingSales < ActiveRecord::Migration[5.1]
  def change
    add_column :event_configurations, :lodging_end_date, :datetime
  end
end
