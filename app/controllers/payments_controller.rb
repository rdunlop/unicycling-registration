class PaymentsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_payments_breadcrumb

  # GET /users/12/payments
  # or
  def index
    @user = User.find_by(params[:user_id])
    @payments = @user.payments.completed
    @refunds = @user.refunds
    @title_name = @user.to_s
  end

  # GET /registrants/1/payments
  def registrant_payments
    registrant = Registrant.find_by(bib_number: params[:id])
    add_registrant_breadcrumb(registrant)
    add_breadcrumb "Payments"

    authorize! :manage, registrant
    @payments = registrant.payments.completed.uniq
    @refunds = registrant.refunds.uniq
    @title_name = registrant.to_s

    render action: "index" # index.html.erb
  end

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
    unless @payment.total_amount == 0
      flash[:alert] = "Please use Paypal to complete the payment"
      redirect_to :back
      return
    end

    @payment.complete(note: "Zero Cost")

    flash[:notice] = "Payment Completed"
    redirect_to user_registrants_path(@payment.user)
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

  private

  def payment_params
    params.require(:payment).permit(payment_details_attributes: [:amount, :registrant_id, :expense_item_id, :details, :free, :_destroy])
  end

  def set_payments_breadcrumb
    if @user == current_user
      add_breadcrumb t("my_payments", scope: "layouts.navbar"), user_payments_path(current_user)
    end
  end
end
