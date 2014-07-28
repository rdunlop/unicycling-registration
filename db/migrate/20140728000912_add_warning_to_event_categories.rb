class AddWarningToEventCategories < ActiveRecord::Migration
  def change
    add_column :event_categories, :warning_on_registration_summary, :boolean, default: false
  end
end
