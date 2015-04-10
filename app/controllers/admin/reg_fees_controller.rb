class Admin::RegFeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_payments_breadcrumb
  before_action :set_reg_fee_breadcrumb

  # GET /payments/set_reg_fees
  def index
    authorize! :set_reg_fee, :registrant
    @reg_fee = RegFee.new
  end

  # POST /payments/update_reg_fee
  # Params: { reg_fee: { registrant_id, registration_period_id } }
  def update_reg_fee
    authorize! :set_reg_fee, :registrant

    @reg_fee = RegFee.new(reg_fee_params)

    if @reg_fee.save
      cost_description = print_formatted_currency(@reg_fee.new_registration_item.cost)
      redirect_to set_reg_fees_path, notice: "Reg Fee For #{@reg_fee.registrant.to_s} Updated Successfully (#{cost_description})"
    else
      set_reg_fee_breadcrumb
      render :index
    end
  end

  private

  def reg_fee_params
    params.require(:reg_fee).permit(:registrant_id, :registration_period_id)
  end

  private

  def set_payments_breadcrumb
    add_breadcrumb "Payment Summary", summary_payments_path
  end

  def set_reg_fee_breadcrumb
    add_breadcrumb "Set Reg Fee"
  end
end
