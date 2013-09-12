class Admin::PaymentsController < Admin::BaseController
  before_filter :authenticate_user!
  before_filter :create_payment, :only => [:create, :onsite_pay_create]
  load_and_authorize_resource

  def create_payment
    @payment = Payment.new(payment_params)
  end

  def load_payment_details
    10.times do
      @payment.payment_details.build()
    end
  end

  def index
    @payments = Payment.all
    @total_received = Payment.total_received
    @expense_groups = ExpenseGroup.all
    @paid_expense_items = Payment.paid_expense_items
    @all_expense_items = Registrant.all_expense_items
  end

  def details
    @details = PaymentDetail.includes(:payment).where("payments.completed = true")
  end

  def new
    load_payment_details
    @payment.payment_date = DateTime.now
  end

  def create
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
    @registrants = Registrant.order(:id).all
  end

  def onsite_pay_confirm
    @payment = Payment.new
    @payment.note = params[:note]
    @registrants = []

    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      reg.build_owing_payment(@payment)
      @registrants << reg
    end
    load_payment_details
  end

  def onsite_pay_create
    @payment.completed = true
    @payment.completed_date = DateTime.now
    @payment.user = current_user

    if @payment.save
      redirect_to payment_path(@payment), notice: "Successfully created payment"
    else
      render "onsite_pay_new"
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:cancelled, :completed, :completed_date, :payment_date, :transaction_id, :note,
                                    :payment_details_attributes => [:amount, :payment_id, :registrant_id, :expense_item_id, :details, :free, :refund])
  end
end
