class Admin::RegistrantsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_registrants_breadcrumb
  before_action :load_registrant, only: [:reg_fee, :update_reg_fee, :undelete]

  # GET /registrants/manage_all
  def manage_all
    authorize! :manage_all, :registrant

    @registrants = Registrant.includes(:user, :contact_detail)
    respond_to do |format|
      format.html { render "manage_all" }
      format.pdf { render :pdf => "manage_all", :template => "registrants/manage_all.html.haml", :formats => [:html], :layout => "pdf.html" }
    end
  end

  # post /registrants/manage_one
  def manage_one
    authorize! :manage_all, :registrant
  end

  # post /registrant/choose_one
  def choose_one
    authorize! :manage_all, :registrant

    if params[:registrant_id].blank?
      flash[:error] = "Choose a Registrant"
      redirect_to manage_one_registrants_path
    else
      registrant = Registrant.find(params[:registrant_id])
      if params[:summary] == "1"
        redirect_to registrant_path(registrant)
      else
        redirect_to registrant_build_path(registrant, :add_name)
      end
    end
  end

  def undelete
    authorize! :undelete, :registrant
    @registrant.deleted = false

    respond_to do |format|
      if @registrant.save(:validate => false) # otherwise the circular validation check for registrant_expense_items fails
        format.html { redirect_to manage_all_registrants_path, notice: 'Registrant was successfully undeleted.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @registrants = Registrant.all
        format.html { render action: "manage_all" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  def bag_labels
    authorize! :bag_labels, :registrant
    @registrants = Registrant.includes(:contact_detail).reorder(:sorted_last_name, :first_name).active.all

    names = []
    @registrants.each do |reg|
      names << "\n <b>##{reg.bib_number}</b> #{reg.last_name}, #{reg.first_name} \n #{reg.country}"
    end

    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align => :center, :size => 12, :inline_format => true
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  def show_all
    authorize! :show_all, :registrant
    @registrants = Registrant.active.reorder(:sorted_last_name, :first_name).includes(:contact_detail, :registrant_expense_items, :registrant_event_sign_ups)

    if params[:offset]
      max = params[:max]
      offset = params[:offset]
      @registrants = @registrants.limit(max).offset(offset)
    end

    respond_to do |format|
      format.html # show_all.html.erb
      format.pdf { render_common_pdf  "show_all",  'Landscape' }
    end
  end

  def reg_fee
    authorize! :set_reg_fee, :registrant
    set_reg_fee_breadcrumb
  end

  def update_reg_fee
    authorize! :set_reg_fee, :registrant
    new_rp = RegistrationPeriod.find(params[:registration_period_id])

    new_reg_item = new_rp.expense_item_for(@registrant.competitor)

    error = false
    # only possible if the registrant is unpaid
    if @registrant.reg_paid?
      error = true
      error_message = "This registrant is already paid"
    end

    respond_to do |format|
      if error || !@registrant.set_registration_item_expense(new_reg_item)
        set_reg_fee_breadcrumb
        format.html { render "reg_fee", alert: error_message  }
      else
        format.html { redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.' }
      end
    end
  end
=begin
  def reg_fee
    @reg_fee = RegFee.new(@registrant)
    set_reg_fee_breadcrumb
  end

  def update_reg_fee
    @reg_fee = RegFee.new(@registrant, attributes)

    if @reg_fee.save
      redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.'
    else
      render :reg_fee
    end
  end

  class RegFee

    def errors
    end

    def save
      # activeattr for validations?
      new_rp = RegistrationPeriod.find(params[:registration_period_id])

      new_reg_item = new_rp.expense_item_for(@registrant.competitor)

      error = false
      # only possible if the registrant is unpaid
      if @registrant.reg_paid?
        error = true
        error_message = "This registrant is already paid"
      end

      respond_to do |format|
        if error || !@registrant.set_registration_item_expense(new_reg_item)
          set_reg_fee_breadcrumb
          format.html { render "reg_fee", alert: error_message  }
        else
          format.html { redirect_to reg_fee_registrant_path(@registrant), notice: 'Reg Fee Updated successfully.' }
        end
      end
    end
  end
=end

  private

  def set_registrants_breadcrumb
    add_breadcrumb "Manage Registrants", manage_one_registrants_path
  end

  def load_registrant
    @registrant = Registrant.find_by(bib_number: params[:id])
  end

  def set_reg_fee_breadcrumb
    add_registrant_breadcrumb(@registrant)
    add_breadcrumb "Set Reg Fee"
  end

  def authorize
    authorize! :manage, :registrants
  end
end
