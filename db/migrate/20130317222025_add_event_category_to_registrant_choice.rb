class AddEventCategoryToRegistrantChoice < ActiveRecord::Migration[4.2]
  def change
    add_column :registrant_choices, :event_category_id, :integer
  end
end
