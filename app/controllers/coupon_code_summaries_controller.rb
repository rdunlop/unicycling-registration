class CouponCodeSummariesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :coupon_code, parent: false

  def show
  end
end
