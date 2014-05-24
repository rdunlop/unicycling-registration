class RegistrantExpenseItemsController < ApplicationController
  before_filter :load_registrant
  before_filter :load_new_registrant_expense_item, only: [:create]
  load_and_authorize_resource
  before_filter :authenticate_user!

  before_action :set_registrant_breadcrumb
  before_action :set_items_breadcrumb, only: [:index]

  def index
  end

  def create
    respond_to do |format|
      format.html {
        if @registrant_expense_item.save
          flash[:notice] = "Successfully created Expense Item"
          redirect_to registrant_registrant_expense_items_path(@registrant)
        else
          set_items_breadcrumb
          render "index", notice: "Error"
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
          redirect_to registrant_registrant_expense_items_path(@registrant)
        else
          set_items_breadcrumb
          render "index", notice: "ERR"
        end
      }
    end
  end

  private
  def registrant_expense_item_params
    params.require(:registrant_expense_item).permit(:expense_item_id, :details, :custom_cost, :free)
  end

  def load_registrant
    @registrant = Registrant.find(params[:registrant_id])
  end

  def load_new_registrant_expense_item
    @registrant_expense_item = RegistrantExpenseItem.new(registrant_expense_item_params)
    @registrant_expense_item.registrant = @registrant
  end

  def set_registrant_breadcrumb
    add_breadcrumb "Registrants", registrants_path
    add_registrant_breadcrumb(@registrant)
  end

  def set_items_breadcrumb
    add_breadcrumb "Items", registrant_registrant_expense_items_path(@registrant)
  end
end
