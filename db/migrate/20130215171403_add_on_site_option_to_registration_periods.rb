class AddOnSiteOptionToRegistrationPeriods < ActiveRecord::Migration
  def change
    add_column :registration_periods, :onsite, :boolean
  end
end
