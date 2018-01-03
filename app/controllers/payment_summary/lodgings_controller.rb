module PaymentSummary
  class LodgingsController < ApplicationController
    before_action :authorize_action

    def show
      @lodging = Lodging.find(params[:id])
      set_breadcrumbs
    end

    private

    def set_breadcrumbs
      add_payment_summary_breadcrumb
      add_breadcrumb "#{@lodging} Items"
    end

    def authorize_action
      authorize current_user, :manage_all_payments?
    end
  end
end
