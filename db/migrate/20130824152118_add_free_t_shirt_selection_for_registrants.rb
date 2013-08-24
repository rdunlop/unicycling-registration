class AddFreeTShirtSelectionForRegistrants < ActiveRecord::Migration
  def change
    add_column :registrants, :free_expense_item_id, :integer
    add_column :event_configurations, :competitor_free_item_expense_group_id, :integer
    add_column :event_configurations, :noncompetitor_free_item_expense_group_id, :integer
  end
end
