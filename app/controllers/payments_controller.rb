class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user, only: :index
  load_and_authorize_resource :except => [:registrant_payments]

  before_action :set_payments_breadcrumb

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
    @expense_items = ExpenseItem.includes(:translations, :expense_group => [:translations]).ordered
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
