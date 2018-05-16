class AddOnSiteOptionToRegistrationPeriods < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_periods, :onsite, :boolean
  end
end
