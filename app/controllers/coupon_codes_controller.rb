class CouponCodesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  respond_to :html

  # GET /coupon_codes
  def index
    @coupon_code = CouponCode.new
  end

  # GET /coupon_codes/1/edit
  def edit
  end

  def show
    add_breadcrumb "Coupon Codes", coupon_codes_path
    add_breadcrumb @coupon_code, @coupon_code
  end

  # POST /coupon_codes
  def create

    respond_to do |format|
      if @coupon_code.save
        format.html { redirect_to coupon_codes_path, notice: 'Coupon Code was successfully created.' }
      else
        @coupon_codes = CouponCode.all
        format.html { render action: "index" }
      end
    end
  end

  # PUT /coupon_codes/1
  def update

    respond_to do |format|
      if @coupon_code.update_attributes(coupon_code_params)
        format.html { redirect_to coupon_codes_path, notice: 'Coupon Code was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /coupon_codes/1
  def destroy
    @coupon_code.destroy

    respond_with(@coupon_code)
  end

  private
  def coupon_code_params
    params.require(:coupon_code).permit(:name, :description, :code, :max_num_uses, :price, expense_item_ids: [])
  end
end
