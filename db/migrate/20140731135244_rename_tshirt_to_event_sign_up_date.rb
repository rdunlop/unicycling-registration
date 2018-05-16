class RenameTshirtToEventSignUpDate < ActiveRecord::Migration[4.2]
  def change
    rename_column :event_configurations, :tshirt_closed_date, :event_sign_up_closed_date
  end
end
