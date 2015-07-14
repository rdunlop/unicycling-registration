class CouponCodeSummariesController < ApplicationController
  before_action :authenticate_user!

  def show
    @coupon_code = CouponCode.find(params[:id])
    authorize :coupon_code_summary
  end
end
