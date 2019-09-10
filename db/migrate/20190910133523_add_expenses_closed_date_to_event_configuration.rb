class AddExpensesClosedDateToEventConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :event_configurations, :add_expenses_end_date, :datetime
  end
end
