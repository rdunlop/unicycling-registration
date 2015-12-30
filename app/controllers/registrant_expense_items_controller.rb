# == Schema Information
#
# Table name: registrant_expense_items
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  expense_item_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#  details           :string(255)
#  free              :boolean          default(FALSE), not null
#  system_managed    :boolean          default(FALSE), not null
#  locked            :boolean          default(FALSE), not null
#  custom_cost_cents :integer
#
# Indexes
#
#  index_registrant_expense_items_expense_item_id  (expense_item_id)
#  index_registrant_expense_items_registrant_id    (registrant_id)
#

class RegistrantExpenseItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_registrant

  before_action :set_registrant_breadcrumb

  def create
    @registrant_expense_item = RegistrantExpenseItem.new(registrant_expense_item_params)
    @registrant_expense_item.registrant = @registrant
    authorize @registrant_expense_item
    respond_to do |format|
      format.html do
        if @registrant_expense_item.save
          flash[:notice] = "Successfully created Expense Item"
          redirect_to :back
        else
          flash[:alert] = @registrant_expense_item.errors.full_messages.join(", ")
          redirect_to :back
        end
      end
    end
  end

  def destroy
    @registrant_expense_item = @registrant.registrant_expense_items.find(params[:id])
    authorize @registrant_expense_item

    respond_to do |format|
      format.html do
        if @registrant_expense_item.destroy
          flash[:notice] = "Successfully removed Expense Item"
          redirect_to :back
        else
          flash[:alert] = "Error Removing Expense Item"
          redirect_to :back
        end
      end
    end
  end

  private

  def registrant_expense_item_params
    params.require(:registrant_expense_item).permit(:expense_item_id, :details, :custom_cost, :free)
  end

  def load_registrant
    @registrant = Registrant.find_by!(bib_number: params[:registrant_id])
  end

  def set_registrant_breadcrumb
    add_registrant_breadcrumb(@registrant)
  end
end
