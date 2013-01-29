class Admin::PaymentsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @payments = Payment.all
    @total_received = Payment.total_received
    @expense_groups = ExpenseGroup.all
    @paid_expense_items = Payment.paid_expense_items
    @all_expense_items = Registrant.all_expense_items
  end
end
