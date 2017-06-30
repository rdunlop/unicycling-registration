class Admin::RegistrantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_registrants_breadcrumb
  before_action :load_registrant, only: %i[really_destroy undelete]

  # GET /registrants/manage_all
  def manage_all
    authorize current_user, :registrant_information?

    @registrants = Registrant.includes(:user, :contact_detail).order(:bib_number)
    respond_to do |format|
      format.html { render "manage_all" }
      format.pdf { render pdf: "manage_all", template: "admin/registrants/manage_all.html.haml", formats: [:html], layout: "pdf.html" }
    end
  end

  # get /registrants/manage_one
  def manage_one
    authorize current_user, :registrant_information?
  end

  # post /registrant/choose_one
  def choose_one
    authorize current_user, :registrant_information?

    registrant = nil
    if params[:bib_number].present?
      registrant = Registrant.find_by!(bib_number: params[:bib_number])
    end

    if params[:registrant_id].present?
      registrant = Registrant.find(params[:registrant_id])
    end

    if registrant.nil?
      flash[:error] = "Choose a Registrant"
      redirect_back(fallback_location: manage_one_registrants_path)
      return
    end

    if params[:summary] == "1"
      redirect_to registrant_path(registrant)
    else
      redirect_to registrant_build_path(registrant, :add_name)
    end
  end

  # DELETE /registrants/1/really_destroy
  def really_destroy
    authorize @registrant
    respond_to do |format|
      if @registrant.destroy
        format.html { redirect_to root_path, notice: 'Registrant deleted' }
      else
        format.html { redirect_to root_path, alert: "Error deleting registrant" }
      end
    end
  end

  def change_registrant_user
    authorize current_user, :change_registrant_user?
    @registrants = Registrant.all
    @users = User.this_tenant.all
  end

  def set_registrant_user
    authorize current_user, :change_registrant_user?
    if params[:registrant_id].present? && params[:user_id].present?
      user_id = params[:user_id]
      registrant = Registrant.find(params[:registrant_id])
      user = User.this_tenant.find(user_id)
      if registrant.update_attribute(:user_id, user_id)
        redirect_to change_registrant_user_registrants_path, notice: "Assigned #{registrant} to user #{user}"
      else
        redirect_to change_registrant_user_registrants_path, alert: "Unable to update registrant"
      end
    else
      redirect_to change_registrant_user_registrants_path, alert: "Registrant and User must both be specified"
    end
  end

  def undelete
    authorize @registrant, :undelete?
    @registrant.deleted = false

    respond_to do |format|
      if @registrant.save(validate: false) # otherwise the circular validation check for registrant_expense_items fails
        format.html { redirect_to manage_all_registrants_path, notice: 'Registrant was successfully undeleted.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        @registrants = Registrant.all
        format.html { render action: "manage_all" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_registrants_breadcrumb
    add_breadcrumb "Manage Registrants", manage_one_registrants_path
  end

  def load_registrant
    @registrant = Registrant.find_by!(bib_number: params[:id])
  end
end
