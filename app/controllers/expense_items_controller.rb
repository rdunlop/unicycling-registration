# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean          default(FALSE), not null
#  maximum_available      :integer
#  has_custom_cost        :boolean          default(FALSE), not null
#  maximum_per_registrant :integer          default(0)
#  cost_cents             :integer
#  tax_cents              :integer          default(0), not null
#
# Indexes
#
#  index_expense_items_expense_group_id  (expense_group_id)
#

class ExpenseItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumbs

  # GET /expense_items/1/details
  def details
    @expense_item = ExpenseItem.find(params[:id])
    authorize current_user, :manage_all_payments?
    @paid_details = @expense_item.paid_items
    @unpaid_details = @expense_item.unpaid_items
    @free_with_registration = @expense_item.free_items
    @refunded_details = @expense_item.refunded_items
  end

  private

  def set_breadcrumbs
    add_payment_summary_breadcrumb
    add_breadcrumb "#{@expense_item} Items"
  end
end
