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
  before_action :load_payment, only: %i[show advanced_stripe complete fake_complete admin_complete apply_coupon]

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
    @expense_groups = ExpenseGroup.includes(:translations)
    @lodgings = Lodging.ordered.all
  end

  # GET /payments/1
  def show
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

  # POST /payments/:id/advanced_stripe
  # Create the StripeSession, and redirect to stripe immediately
  def advanced_stripe
    authorize @payment
    unless @config.payment_type == "advanced_stripe"
      flash[:alert] = "Error, not correct stripe configuration"
      redirect_to root_path
      return
    end
    line_items = []
    @payment.unique_payment_details.each do |pd|
      next if pd.amount == 0.to_money

      # This must be in the format of "12.34" (no commas)
      line_items << {
        price_data: {
          currency: @config.currency_code,
          product_data: {
            name: pd.to_s
          },
          unit_amount: pd.amount_cents
        },
        quantity: pd.count.to_s
      }
    end

    Stripe.api_key = @config.stripe_secret_key
    # If we don't specify the version, we're at the
    # whims of the associated stripe account configuration
    Stripe.api_version = "2022-11-15"

    # Reference: https://stripe.com/docs/api/checkout/sessions/create
    stripe_session = Stripe::Checkout::Session.create(
      client_reference_id: @payment.invoice_id,
      customer_email: @payment.user.email,
      locale: I18n.locale,
      metadata: {
        uni_invoice_id: @payment.invoice_id
      },
      mode: "payment",
      success_url: success_payments_url,
      cancel_url: user_payments_url(current_user),
      payment_method_types: ['card'],
      line_items: line_items,
      submit_type: "pay"
    )
    @session_id = stripe_session.id
    # renders the page, which then redirects to stripe.com for capture
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

  def fake_complete
    authorize @payment

    @payment.complete(note: "Fake_Complete")

    redirect_to root_path
  end

  def apply_coupon
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
    authorize @payment

    if @payment.complete(note: params[:payment][:note])
      ManualPaymentReceiver.send_emails(@payment)
      redirect_to payment_path(@payment), notice: "Successfully created payment and sent e-mail"
    else
      redirect_to user_payments_path(current_user)
    end
  end

  private

  def load_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(payment_details_attributes: %i[amount registrant_id line_item_id line_item_type details free _destroy])
  end

  def set_payments_breadcrumb
    if @user == current_user
      add_breadcrumb t("my_payments", scope: "nav_bar.top_nav"), user_payments_path(current_user)
    end
  end
end
