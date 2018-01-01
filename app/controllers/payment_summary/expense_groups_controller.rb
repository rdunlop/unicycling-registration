module PaymentSummary
  class ExpenseGroupsController < ApplicationController
    before_action :authorize_action

    def show
      @expense_group = ExpenseGroup.find(params[:id])
      set_breadcrumbs
      @expense_items = @expense_group.expense_items.includes(:translations).ordered
    end

    private

    def set_breadcrumbs
      add_payment_summary_breadcrumb
      add_breadcrumb "#{@expense_group} Items"
    end

    def authorize_action
      authorize Payment.new, :summary?
    end
  end
end
