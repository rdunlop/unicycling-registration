class Admin::ManualRefundsController < ApplicationController
  before_action :set_breadcrumbs
  before_action :authorize_payment_admin

  def new
    @registrants = Registrant.order(:bib_number)
  end

  def choose
    add_breadcrumb "Choose Refund Items"

    @manual_refund = ManualRefund.new
    params[:registrant_ids].each do |reg_id|
      registrant = Registrant.find(reg_id)
      @manual_refund.add_registrant(registrant)
    end
  end

  def create
    @manual_refund = ManualRefund.new(params[:manual_refund])
    @manual_refund.user = current_user

    if @manual_refund.save
      redirect_to root_path, notice: "Successfully created refund"
    else
      add_breadcrumb "Choose Refund Items"
      render :choose
    end
  end

  private

  def authorize_payment_admin
    authorize current_user, :manage_all_payments?
  end

  def set_breadcrumbs
    add_breadcrumb "Payments Management", summary_payments_path
    add_breadcrumb "New Manual Refund", new_manual_refund_path
  end
end
