class PaymentAdjustmentsController < ApplicationController
  before_action :authenticate_user!
  load_resource :payment
  authorize_resource class: false

  def list
    add_breadcrumb "Payment Management", summary_payments_path
    add_breadcrumb "Payments and Refunds"
    @payments = Payment.includes(:user)
    @refunds = Refund.includes(:user)
  end

  def new
    @registrants = Registrant.order(:bib_number)
  end

  def adjust_payment_choose
    if params[:registrant_id].nil?
      flash[:alert] = "You must choose at least 1 registrant"
      redirect_to action: "new"
    else
      @p = PaymentPresenter.new
      params[:registrant_id].each do |reg_id|
        reg = Registrant.find(reg_id)
        @p.add_registrant(reg)
      end
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

  def exchange_choose
    @registrants = []

    params[:registrant_id].each do |reg_id|
      @registrants << Registrant.find(reg_id)
    end
  end

  def exchange_create
    note = params[:note]
    reg_id = params[:registrant_id]
    old_item_id = params[:old_item_id]
    new_item_id = params[:new_item_id]

    registrant = Registrant.find(reg_id)
    if note.present? && reg_id.present? && old_item_id.present? && new_item_id.present?

      begin
        old_item = ExpenseItem.find(old_item_id)
        new_item = ExpenseItem.find(new_item_id)
        refund = Refund.build_from_details(
          note: note,
          registrant: registrant,
          item: old_item)
        refunded_pd = refund.refund_details.first.payment_detail
        raise "Unable to find matching paid expense item" unless refunded_pd
        payment = Payment.build_from_details(
          note: note,
          registrant: registrant,
          details: refunded_pd.details,
          amount: refunded_pd.amount,
          item: new_item)
        Refund.transaction do
          refund.user = current_user
          payment.user = current_user
          refund.save!
          payment.save!
        end
        flash.now[:notice] = "Exchanged #{old_item} for #{new_item}"
      rescue Exception => ex
        flash.now[:alert] = "Error creating exchange #{ex}"
      end
    else
      flash.now[:alert] = "Must fill in all fields"
    end

    @registrants = [registrant.reload]
    render "exchange_choose"
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
