class Admin::ManualPaymentsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: false

  def new
    @registrants = Registrant.order(:bib_number)
  end

  def choose
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
end
