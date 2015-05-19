class RegistrantExpenseItemsController < ApplicationController
  before_action :load_registrant
  before_action :load_new_registrant_expense_item, only: [:create]
  load_and_authorize_resource
  before_action :authenticate_user!

  before_action :set_registrant_breadcrumb

  def create
    respond_to do |format|
      format.html {
        if @registrant_expense_item.save
          flash[:notice] = "Successfully created Expense Item"
          redirect_to :back
        else
          flash[:alert] = @registrant_expense_item.errors.full_messages.join(", ")
          redirect_to :back
        end
      }
    end
  end

  def destroy
    @registrant_expense_item = @registrant.registrant_expense_items.find(params[:id])

    respond_to do |format|
      format.html {
        if @registrant_expense_item.destroy
          flash[:notice] = "Successfully removed Expense Item"
          redirect_to :back
        else
          flash[:alert] = "Error Removing Expense Item"
          redirect_to :back
        end
      }
    end
  end

  private

  def registrant_expense_item_params
    params.require(:registrant_expense_item).permit(:expense_item_id, :details, :custom_cost, :free)
  end

  def load_registrant
    @registrant = Registrant.find_by!(bib_number: params[:registrant_id])
  end

  def load_new_registrant_expense_item
    @registrant_expense_item = RegistrantExpenseItem.new(registrant_expense_item_params)
    @registrant_expense_item.registrant = @registrant
  end

  def set_registrant_breadcrumb
    add_registrant_breadcrumb(@registrant)
  end
end
