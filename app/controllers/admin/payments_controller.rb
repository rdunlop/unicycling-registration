class Admin::PaymentsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @payments = Payment.all
  end
end
