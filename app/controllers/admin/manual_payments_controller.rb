class Admin::ManualPaymentsController < ApplicationController
  before_action :set_breadcrumbs
  before_action :authorize_payment_admin

  def new
    @registrants = Registrant.order(:bib_number)
  end

  def choose
    add_breadcrumb "Choose Payment Items"

    @manual_payment = ManualPayment.new
    params[:registrant_ids].each do |reg_id|
      registrant = Registrant.find(reg_id)
      @manual_payment.add_registrant(registrant)
    end
  end

  def create
    @manual_payment = ManualPayment.new(params[:manual_payment])
    @manual_payment.user = current_user

    if @manual_payment.save
      payment = @manual_payment.saved_payment
      users = payment.payment_details.map(&:registrant).map(&:user).flatten.uniq
      users.each do |user|
        PaymentMailer.manual_payment_completed(payment, user).deliver_later
      end
      redirect_to payment_path(payment), notice: "Successfully created payment and sent e-mail"
    else
      add_breadcrumb "Choose Payment Items"
      render :choose
    end
  end

  private

  def authorize_payment_admin
    authorize current_user, :manage_all_payments?
  end

  def set_breadcrumbs
    add_breadcrumb "Payments Management", summary_payments_path
    add_breadcrumb "New Manual Payment", new_manual_payment_path
  end
end
