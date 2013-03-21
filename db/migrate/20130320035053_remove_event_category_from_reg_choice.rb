class RemoveEventCategoryFromRegChoice < ActiveRecord::Migration
  def up
    remove_column :registrant_choices, :event_category_id
  end

  def down
    add_column :registrant_choices, :event_category_id, :integer
  end
end
