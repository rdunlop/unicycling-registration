# == Schema Information
#
# Table name: payments
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  completed            :boolean          default(FALSE), not null
#  cancelled            :boolean          default(FALSE), not null
#  transaction_id       :string(255)
#  completed_date       :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  payment_date         :string(255)
#  note                 :string(255)
#  invoice_id           :string(255)
#  offline_pending      :boolean          default(FALSE), not null
#  offline_pending_date :datetime
#
# Indexes
#
#  index_payments_user_id  (user_id)
#

class PaymentsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_payments_breadcrumb

  # GET /users/12/payments
  # or
  def index
    @user = User.this_tenant.find(params[:user_id])
    authorize @user, :payments?

    @payments = @user.payments.completed_or_offline
    @refunds = @user.refunds
    @title_name = @user.to_s
  end

  # GET /registrants/1/payments
  def registrant_payments
    registrant = Registrant.find_by!(bib_number: params[:id])
    authorize registrant, :payments?

    add_registrant_breadcrumb(registrant)
    add_breadcrumb "Payments"

    @payments = registrant.payments.completed_or_offline.distinct
    @refunds = registrant.refunds.uniq
    @title_name = registrant.to_s

    render action: "index" # index.html.erb
  end

  # Display offline payment instructions
  def offline
    authorize Payment.new, :offline_payment?
    add_breadcrumb t("my_registrants", scope: "breadcrumbs"), user_registrants_path(current_user)
  end

  # /payments/summary
  def summary
    add_payment_summary_breadcrumb
    authorize Payment.new
    @expense_items = ExpenseItem.includes(:translations, expense_group: [:translations]).ordered
  end

  # GET /payments/1
  def show
    @payment = Payment.find(params[:id])
    authorize @payment
    add_breadcrumb t("new_payment", scope: "breadcrumbs")
  end

  # GET /payments/new
  def new
    @payment = Payment.new
    authorize @payment
    add_breadcrumb t("new_payment", scope: "breadcrumbs")
    payment_creator = PaymentCreator.new(@payment)
    current_user.accessible_registrants.each do |reg|
      payment_creator.add_registrant(reg)
    end
  end

  # POST /payments
  def create
    if params[:payment].nil?
      flash[:alert] = "No Payment selected"
      skip_authorization
      redirect_to new_payment_path
      return
    end

    @payment = Payment.new(payment_params)
    @payment.user = current_user
    authorize @payment

    if @payment.save
      redirect_to @payment, notice: 'Payment was successfully created.'
    else
      render action: "new"
    end
  end

  def complete
    @payment = Payment.find(params[:id])
    authorize @payment
    unless @payment.total_amount == 0.to_money
      flash[:alert] = "Please use Paypal to complete the payment"
      redirect_back(fallback_location: payment_path(@payment))
      return
    end

    @payment.complete(note: "Zero Cost")

    flash[:notice] = "Payment Completed"
    redirect_to user_registrants_path(@payment.user)
  end

  # User has agreed that they will make an offline payment
  # As a result, we commit these expenses to a payment
  def pay_offline
    @payment = Payment.find(params[:id])
    authorize @payment
    if @payment.total_amount == 0.to_money
      @payment.complete(note: "Zero Cost")
      return
    end

    if @payment.offline_pay
      flash[:notice] = "Payment Marked as an Offline Payment"
      redirect_to user_registrants_path(@payment.user)
    else
      flash[:alert] = "Error marking payment ready for offline payment #{@payment.errors.full_messages}"
      redirect_to payment_path(@payment)
    end
  end

  def fake_complete
    @payment = Payment.find(params[:id])
    authorize @payment

    @payment.complete(note: "Fake_Complete")

    redirect_to root_path
  end

  def apply_coupon
    @payment = Payment.find(params[:id])
    authorize @payment

    action = CouponApplier.new(@payment, params[:coupon_code])
    if action.perform
      flash[:notice] = "Success applying coupon"
    else
      flash[:alert] = action.error
    end
    redirect_to @payment
  end

  def admin_complete
    payment = Payment.find(params[:id])
    authorize payment

    if payment.complete(note: params[:payment][:note])
      ManualPaymentReceiver.send_emails(payment)
      redirect_to payment_path(payment), notice: "Successfully created payment and sent e-mail"
    else
      redirect_to user_payments_path(current_user)
    end
  end

  private

  def payment_params
    params.require(:payment).permit(payment_details_attributes: %i[amount registrant_id expense_item_id details free _destroy])
  end

  def set_payments_breadcrumb
    if @user == current_user
      add_breadcrumb t("my_payments", scope: "nav_bar.top_nav"), user_payments_path(current_user)
    end
  end
end
