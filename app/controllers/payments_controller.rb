class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user, only: :index
  load_and_authorize_resource :except => [:registrant_payments]

  before_action :set_payments_breadcrumb

  # GET /users/12/payments
  # or
  # GET /registrants/1/payments
  def index
    @payments = @user.payments.completed
    @refunds = @user.refunds
    @title_name = @user.to_s
  end

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
    add_breadcrumb t("my_registrants", scope: "breadcrumbs"), user_registrants_path(current_user)
  end

  def summary
    add_payment_summary_breadcrumb
    @expense_items = ExpenseItem.includes(:translations, :expense_group => [:translations]).ordered
  end

  # GET /payments/1
  def show
    add_breadcrumb "New Payment"
  end

  # GET /payments/new
  def new
    add_breadcrumb "New Payment"
    payment_creator = PaymentCreator.new(@payment)
    current_user.accessible_registrants.each do |reg|
      payment_creator.add_registrant(reg)
    end
  end

  # POST /payments
  def create
    @payment.user = current_user

    if @payment.save
      redirect_to @payment, notice: 'Payment was successfully created.'
      render json: @payment, status: :created, location: @payment
    else
      render action: "new"
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  def complete
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
    @payment.complete(note: "Fake_Complete")

    redirect_to root_path
  end

  def apply_coupon
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
    params.require(:payment).permit(:payment_details_attributes => [:amount, :registrant_id, :expense_item_id, :details, :free, :_destroy])
  end

  def set_payments_breadcrumb
    if @user == current_user
      add_breadcrumb "My Payments", user_payments_path(current_user)
    end
  end
end
