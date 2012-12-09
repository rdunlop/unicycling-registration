class RegistrantExpensesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :except => [:single]
  skip_authorization_check :only => [:single]

  respond_to :html, :js

  # AJAX call to render the new expenses line item(s)
  def single
    @registrant_expense_item = RegistrantExpenseItem.new(params[:registrant_expense_item])

    respond_with @registrant_expense_item, :location => "/registrants/expenses"
  end
end
