class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:notification, :success]
  load_and_authorize_resource :except => [:notification, :success]
  skip_load_resource only: [:create]
  skip_authorization_check :only => [:notification, :success]
  skip_before_filter :verify_authenticity_token, :only => [:notification, :success]

  # GET /payments
  # GET /payments.json
  def index
    @payments = current_user.payments.completed

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payments }
    end
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
    current_user.accessible_registrants.each do |reg|
      reg.build_owing_payment(@payment)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)
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

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  def fake_complete
    @payment.completed = true
    @payment.note = "Fake_Complete"
    @payment.save!

    respond_to do |format|
      format.html { redirect_to registrants_path }
    end
  end

  # PayPal notification endpoint
  def notification
    paypal = PaypalConfirmer.new(params, request.raw_post)
    if paypal.valid?
      if paypal.correct_paypal_account? and paypal.completed?
        if Payment.exists?(paypal.order_number)
          payment = Payment.find(paypal.order_number)
          if payment.completed
            Notifications.ipn_received("Payment already completed " + paypal.order_number).deliver
          else
            payment.completed = true
            payment.transaction_id = paypal.transaction_id
            payment.completed_date = DateTime.now
            payment.payment_date = paypal.payment_date
            payment.save
            Notifications.payment_completed(payment).deliver
            Notifications.ipn_received("Payment Received #{params}")
            if payment.total_amount.to_s != paypal.payment_amount
              Notifications.ipn_received("Payment total (#{payment.total_amount} not equal to the paypal amount #{paypal.payment_amount}").deliver
            end
          end
        else
          Notifications.ipn_received("Unable to find Payment " + paypal.order_number).deliver
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
end
