class PaymentAdjustmentsController < ApplicationController
  before_filter :authenticate_user!
  load_resource :payment
  authorize_resource class: false

  def list
    @payments = Payment.includes(:user)
    @refunds = Refund.includes(:user)
  end

  def new
    @registrants = Registrant.order(:bib_number)
  end

  def adjust_payment_choose
    @p = PaymentPresenter.new

    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      @p.add_registrant(reg)
    end
  end

  def onsite_pay_choose
    @p = PaymentPresenter.new

    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      @p.add_registrant(reg)
    end
  end

  def refund_choose
    @refund_presenter = RefundPresenter.new

    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      @refund_presenter.add_registrant(reg)
    end
  end

  def refund_create
    @refund_presenter= RefundPresenter.new(params[:refund_presenter])
    @refund_presenter.user = current_user

    if @refund_presenter.save
      redirect_to list_payment_adjustments_path, notice: "Successfully created refund"
    else
      render "refund_choose"
    end
  end

  def onsite_pay_confirm
    @p = PaymentPresenter.new

    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      @p.add_registrant(reg)
    end
  end

  def onsite_pay_create
    @p = PaymentPresenter.new(params[:payment_presenter])
    @p.user = current_user

    if @p.save
      redirect_to payment_path(@p.saved_payment), notice: "Successfully created payment"
    else
      render "onsite_pay_confirm"
    end
  end
end
