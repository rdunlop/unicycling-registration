class Admin::RegFeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payments_breadcrumb

  # GET /payments/set_reg_fees
  def index
    authorize! :set_reg_fee, :registrant
    set_reg_fee_breadcrumb
  end

  # POST /payments/update_reg_fee
  # Params: { registrant_id, registration_period_id }
  def update_reg_fee
    authorize! :set_reg_fee, :registrant

    registrant = Registrant.find(params[:registrant_id])
    new_rp = RegistrationPeriod.find(params[:registration_period_id])

    new_reg_item = new_rp.expense_item_for(registrant.competitor)

    error = false
    # only possible if the registrant is unpaid
    if registrant.reg_paid?
      error = true
      error_message = "This registrant is already paid"
    end

    if error || !registrant.set_registration_item_expense(new_reg_item)
      set_reg_fee_breadcrumb
      flash.now[:alert] = error_message
      render :index
    else
      redirect_to set_reg_fees_path, notice: 'Reg Fee Updated successfully.'
    end
  end
  #   def reg_fee
  #     @reg_fee = RegFee.new(@registrant)
  #     set_reg_fee_breadcrumb
  #   end
  #
  #   def update_reg_fee
  #     @reg_fee = RegFee.new(@registrant, attributes)
  #
  #     if @reg_fee.save
  #       redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.'
  #     else
  #       render :reg_fee
  #     end
  #   end
  #
  #   class RegFee
  #
  #     def errors
  #     end
  #
  #     def save
  #       # activeattr for validations?
  #       new_rp = RegistrationPeriod.find(params[:registration_period_id])
  #
  #       new_reg_item = new_rp.expense_item_for(@registrant.competitor)
  #
  #       error = false
  #       # only possible if the registrant is unpaid
  #       if @registrant.reg_paid?
  #         error = true
  #         error_message = "This registrant is already paid"
  #       end
  #
  #       respond_to do |format|
  #         if error || !@registrant.set_registration_item_expense(new_reg_item)
  #           set_reg_fee_breadcrumb
  #           format.html { render "reg_fee", alert: error_message  }
  #         else
  #           format.html { redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.' }
  #         end
  #       end
  #     end
  #   end

  private

  def set_payments_breadcrumb
    add_breadcrumb "Payment Summary", summary_payments_path
  end

  def set_reg_fee_breadcrumb
    add_breadcrumb "Set Reg Fee"
  end
end
