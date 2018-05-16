class AddWarningToEventCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :event_categories, :warning_on_registration_summary, :boolean, default: false
  end
end
