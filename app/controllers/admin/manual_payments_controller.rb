class Admin::ManualPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumbs
  authorize_resource class: false

  def new
    add_breadcrumb "New Manual Payment"
    @registrants = Registrant.order(:bib_number)
  end

  def choose
    add_breadcrumb "New Manual Payment", new_manual_payment_path
    add_breadcrumb "Choose Payment Items"

    @payment_presenter = ManualPayment.new
    params[:registrant_ids].each do |reg_id|
      registrant = Registrant.find(reg_id)
      @payment_presenter.add_registrant(registrant)
    end
  end

  def create
    @payment_presenter = ManualPayment.new(params[:manual_payment])
    @payment_presenter.user = current_user

    if @payment_presenter.save
      redirect_to payment_path(@payment_presenter.saved_payment), notice: "Successfully created payment"
    else
      render :choose
    end
  end

  private

  def set_breadcrumbs
    add_breadcrumb "Payments Management", summary_payments_path
  end
end
