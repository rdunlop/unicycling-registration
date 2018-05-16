class RemoveEventCategoryFromRegChoice < ActiveRecord::Migration[4.2]
  def up
    remove_column :registrant_choices, :event_category_id
  end

  def down
    add_column :registrant_choices, :event_category_id, :integer
  end
end
