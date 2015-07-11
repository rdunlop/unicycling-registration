class CouponCodeSummariesController < ApplicationController

  def show
    @coupon_code = CouponCode.find(params[:id])
    authorize :coupon_code_summary
  end
end
