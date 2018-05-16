class AddPageIdOptionToExpenseGroupAndCompNoncomp < ActiveRecord::Migration[4.2]
  def change
    add_column :expense_groups, :info_page_id, :integer
    add_column :event_configurations, :comp_noncomp_page_id, :integer
  end
end
