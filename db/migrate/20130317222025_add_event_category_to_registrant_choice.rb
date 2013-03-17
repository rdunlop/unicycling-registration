class AddEventCategoryToRegistrantChoice < ActiveRecord::Migration
  def change
    add_column :registrant_choices, :event_category_id, :integer
  end
end
