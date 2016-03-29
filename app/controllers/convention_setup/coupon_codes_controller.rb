class ConventionSetup::CouponCodesController < ConventionSetup::BaseConventionSetupController
  before_action :load_coupon_code, except: [:index, :create]
  before_action :authorize_setup

  before_action :set_breadcrumbs

  respond_to :html

  # GET /convention_setup/coupon_codes
  def index
    @coupon_code = CouponCode.new
    @coupon_codes = CouponCode.all
  end

  # GET /convention_setup/coupon_codes/1/edit
  def edit
    add_breadcrumb "Edit Coupon Code"
  end

  # POST /convention_setup/coupon_codes
  def create
    @coupon_code = CouponCode.new(coupon_code_params)
    respond_to do |format|
      if @coupon_code.save
        format.html { redirect_to coupon_codes_path, notice: 'Coupon Code was successfully created.' }
      else
        @coupon_codes = CouponCode.all
        format.html { render action: "index" }
      end
    end
  end

  # PUT /convention_setup/coupon_codes/1
  def update
    respond_to do |format|
      if @coupon_code.update_attributes(coupon_code_params)
        format.html { redirect_to coupon_codes_path, notice: 'Coupon Code was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /convention_setup/coupon_codes/1
  def destroy
    @coupon_code.destroy

    respond_with(@coupon_code)
  end

  private

  def load_coupon_code
    @coupon_code = CouponCode.find(params[:id])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def set_breadcrumbs
    add_breadcrumb "Coupon Codes", coupon_codes_path
  end

  def coupon_code_params
    params.require(:coupon_code).permit(:name, :description, :inform_emails, :maximum_registrant_age, :code, :max_num_uses, :price, expense_item_ids: [])
  end
end
