class Admin::PendingPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumbs
  before_action :authorize_payment_admin

  def pay
    payment = Payment.find(params[:id])

    if payment.complete(payment_params)
      flash[:notice] = "Successfully marked as paid and sent emails"
      ManualPaymentReceiver.send_emails(payment)
      redirect_to payment_path(payment)
    else
      flash[:alert] = "Unable to mark payment as received"
      redirect_to :back
    end
  end

  private

  def authorize_payment_admin
    authorize current_user, :manage_all_payments?
  end

  def set_breadcrumbs
    add_breadcrumb "Payments Management", summary_payments_path
    add_breadcrumb "Manual Payments", new_manual_payment_path
  end

  def payment_params
    params.require(:payment).permit(:note)
  end
end
