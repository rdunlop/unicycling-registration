module PaymentSummary
  class LodgingsController < ApplicationController
    before_action :authorize_action

    def show
      @lodging = Lodging.find(params[:id])
      @paid_packages = LodgingPackage
                       .joins(:lodging_room_type, :payment_details)
                       .includes(:lodging_room_option, :lodging_package_days)
                       .merge(PaymentDetail.paid.where(refunded: false))
                       .merge(LodgingRoomType.where(lodging: @lodging))
      @selected_packages = LodgingPackage
                           .joins(:lodging_room_type, :registrant_expense_items)
                           .includes(:lodging_room_option, :lodging_package_days)
                           .merge(LodgingRoomType.where(lodging: @lodging))
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
