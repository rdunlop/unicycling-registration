class Admin::PaymentsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_load_resource only: [:create]

  def load_payment_details
    10.times do
      @payment.payment_details.build()
    end
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
    authorize! :create, @payment

    if @payment.save
      redirect_to payments_url, notice: "Successfully created payment"
    else
      load_payment_details
      render "new"
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:cancelled, :completed, :completed_date, :payment_date, :transaction_id, :note,
                                    :payment_details_attributes => [:amount, :payment_id, :registrant_id, :expense_item_id, :details, :free, :refund])
  end
end
