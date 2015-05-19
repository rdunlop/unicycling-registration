class RemoveBaseTranslationColmuns < ActiveRecord::Migration
  def change
    remove_column :categories, :name, :string

    remove_column :event_choices, :label, :string
    remove_column :event_choices, :tooltip, :string

    remove_column :event_configurations, :short_name, :string
    remove_column :event_configurations, :long_name, :string
    remove_column :event_configurations, :location, :string
    remove_column :event_configurations, :dates_description, :string

    remove_column :expense_groups, :group_name, :string

    remove_column :expense_items, :name, :string
    remove_column :expense_items, :details_label, :string

    remove_column :registration_periods, :name, :string
  end
end
