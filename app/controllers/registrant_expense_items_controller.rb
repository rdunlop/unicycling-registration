class RegistrantExpenseItemsController < ApplicationController
  load_and_authorize_resource
  before_filter :load_registrant
  before_filter :authenticate_user!

  def load_registrant
    @registrant = Registrant.find(params[:registrant_id])
  end

  def create
    @registrant_expense_item = RegistrantExpenseItem.new(params[:registrant_expense_item])
    @registrant_expense_item.registrant = @registrant

    respond_to do |format|
      format.html {
        if @registrant_expense_item.save
          redirect_to items_registrant_path(@registrant)
        else
          render "/registrants/items", notice: "Error"
        end
      }
    end
  end

  def destroy
    @registrant_expense_item = RegistrantExpenseItem.find(params[:id])

    respond_to do |format|
      format.html {
        if @registrant_expense_item.destroy
          redirect_to items_registrant_path(@registrant)
        else
          render "/registrants/items", notice: "ERR"
        end
      }
    end
  end
end
