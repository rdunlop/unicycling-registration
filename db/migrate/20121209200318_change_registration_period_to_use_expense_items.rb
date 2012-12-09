class ChangeRegistrationPeriodToUseExpenseItems < ActiveRecord::Migration
  def up
    add_column :registration_periods, :competitor_expense_item_id, :integer
    add_column :registration_periods, :noncompetitor_expense_item_id, :integer
    remove_column :registration_periods, :competitor_cost
    remove_column :registration_periods, :noncompetitor_cost
  end
end
