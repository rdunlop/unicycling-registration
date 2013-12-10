class Admin::PaymentsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_load_resource only: [:create]

  def load_payment_details
    10.times do
      @payment.payment_details.build()
    end
  end

  def index
    @payments = Payment.includes(:user).all
    @refunds = Refund.includes(:user).all
  end

  def summary
    @total_received = Payment.total_received
    @expense_groups = ExpenseGroup.includes(:expense_items => [:translations, :expense_group]).all
  end

  def details
    @details = PaymentDetail.completed
  end

  def new
    load_payment_details
    @payment.payment_date = DateTime.now
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.payment_details.each do |pd|
      pd.amount = pd.expense_item.total_cost
    end
    @payment.completed = true
    @payment.completed_date = DateTime.now
    @payment.user = current_user

    if @payment.save
      redirect_to payments_url, notice: "Successfully created payment"
    else
      load_payment_details
      render "new"
    end
  end

  def onsite_pay_new
    @registrants = Registrant.order(:bib_number).all
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
    @p = RefundPresenter.new

    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      @p.add_registrant(reg)
    end
  end

  def refund_create
    @p = RefundPresenter.new(params[:refund_presenter])
    @p.user = current_user

    if @p.save
      redirect_to admin_payments_path, notice: "Successfully created refund"
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

  private

  def payment_params
    params.require(:payment).permit(:cancelled, :completed, :completed_date, :payment_date, :transaction_id, :note,
                                    :payment_details_attributes => [:amount, :payment_id, :registrant_id, :expense_item_id, :details, :free, :refund])
  end
end
