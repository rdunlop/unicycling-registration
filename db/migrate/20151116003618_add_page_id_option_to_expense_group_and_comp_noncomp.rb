class AddPageIdOptionToExpenseGroupAndCompNoncomp < ActiveRecord::Migration
  def change
    add_column :expense_groups, :info_page_id, :integer
    add_column :event_configurations, :comp_noncomp_page_id, :integer
  end
end
