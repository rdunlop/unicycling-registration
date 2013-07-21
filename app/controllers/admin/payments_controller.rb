class Admin::PaymentsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

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
      pd.amount = pd.expense_item.cost
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

  def onsite_pay_create
    @payment = Payment.new
    @payment.completed = true
    @payment.completed_date = DateTime.now
    @payment.user = current_user
    @payment.note = params[:note]

    @registrants = []
    params[:registrant_id].each do |reg_id|
      reg = Registrant.find(reg_id)
      @registrants << reg
      reg.build_owing_payment(@payment)
    end

    if @payment.save
      redirect_to admin_payments_url, notice: "Successfully created payment"
    else
      render "onsite_pay_new"
    end
  end

end
