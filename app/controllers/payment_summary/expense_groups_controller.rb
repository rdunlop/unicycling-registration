module PaymentSummary
  class ExpenseGroupsController < ApplicationController
    before_action :authorize_action

    def index
      @expense_items = ExpenseItem.includes(:translations, expense_group: [:translations]).ordered
    end

    def show
      @expense_group = ExpenseGroup.find(params[:id])
      @expense_items = @expense_group.expense_items.includes(:translations).ordered
    end

    private

    def authorize_action
      authorize Payment.new, :summary?
    end
  end
end
