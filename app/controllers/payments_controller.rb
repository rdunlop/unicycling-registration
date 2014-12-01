class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:notification, :success]
  load_and_authorize_resource :user, only: :index
  load_and_authorize_resource :except => [:registrant_payments, :notification, :success]
  skip_authorization_check :only => [:notification, :success]
  skip_before_filter :verify_authenticity_token, :only => [:notification, :success]

  before_action :set_payments_breadcrumb, except: [:notification, :success]

  # GET /users/12/payments
  # GET /users/12/payments.json
  # or
  # GET /registrants/1/payments
  def index
    @payments = @user.payments.completed
    @refunds = @user.refunds
    @title_name = @user.to_s

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
    end
  end

  def registrant_payments
    registrant = Registrant.find_by(bib_number: params[:id])
    add_registrant_breadcrumb(registrant)
    add_breadcrumb "Payments"

    authorize! :manage, registrant
    @payments = registrant.payments.completed.uniq
    @refunds = registrant.refunds.uniq
    @title_name = registrant.to_s

    respond_to do |format|
      format.html { render action: "index" }# index.html.erb
      format.json { render json: @payments }
    end
  end

  def summary
    add_payment_summary_breadcrumb
    @expense_items = ExpenseItem.includes(:translations, :expense_group => [:translations])
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.json
  def new
    payment_creator = PaymentCreator.new(@payment)
    current_user.accessible_registrants.each do |reg|
      payment_creator.add_registrant(reg)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment.user = current_user

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render json: @payment, status: :created, location: @payment }
      else
        format.html { render action: "new" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def complete
    unless @payment.total_amount == 0
      flash[:alert] = "Please use Paypal to complete the payment"
      redirect_to :back
      return
    end

    @payment.complete(note: "Zero Cost")

    respond_to do |format|
      flash[:notice] = "Payment Completed"
      format.html { redirect_to user_registrants_path(@payment.user) }
    end
  end

  def fake_complete
    @payment.complete(note: "Fake_Complete")

    respond_to do |format|
      format.html { redirect_to root_path }
    end
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

  # PayPal notification endpoint
  def notification
    paypal = PaypalConfirmer.new(params, request.raw_post)
    if paypal.valid?
      if paypal.correct_paypal_account? and paypal.completed?
        if Payment.exists?(paypal.order_number)
          payment = Payment.find(paypal.order_number)
          if payment.completed
            PaymentMailer.delay.ipn_received("Payment already completed " + paypal.order_number)
          else
            payment.complete(transaction_id: paypal.transaction_id, payment_date: paypal.payment_date)
            PaymentMailer.delay.payment_completed(payment.id)
            if payment.total_amount != paypal.payment_amount
              PaymentMailer.delay.ipn_received("Payment total #{payment.total_amount} not equal to the paypal amount #{paypal.payment_amount}")
            end
          end
        else
          PaymentMailer.delay.ipn_received("Unable to find Payment " + paypal.order_number)
        end
      end
    end
    render :nothing => true
  end

  # PayPal return endpoint
  def success
  end

  private

  def payment_params
    params.require(:payment).permit(:payment_details_attributes => [:amount, :registrant_id, :expense_item_id, :details, :free, :_destroy])
  end

  def set_payments_breadcrumb
    if @user == current_user
      add_breadcrumb "My Payments", user_payments_path(current_user)
    else
      add_breadcrumb "New Payment"
    end
  end
end
