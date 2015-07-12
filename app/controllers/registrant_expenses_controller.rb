class RegistrantExpensesController < ApplicationController
  before_action :authenticate_user!
  skip_authorization

  respond_to :js

  # AJAX call to render the new expenses line item(s)
  def single
    @registrant_expense_item = RegistrantExpenseItem.new(params[:registrant_expense_item])

    respond_with @registrant_expense_item, location: "/registrants/expenses"
  end
end
