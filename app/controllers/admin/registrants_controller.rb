class Admin::RegistrantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_registrants_breadcrumb
  before_action :load_registrant, only: [:undelete]

  # GET /registrants/manage_all
  def manage_all
    authorize current_user, :registrant_information?

    @registrants = Registrant.includes(:user, :contact_detail)
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
      redirect_to :back
      return
    end

    if params[:summary] == "1"
      redirect_to registrant_path(registrant)
    else
      redirect_to registrant_build_path(registrant, :add_name)
    end
  end

  def change_registrant_user
    authorize current_user, :change_registrant_user?
    @registrants = Registrant.all
    @users = User.all
  end

  def set_registrant_user
    authorize current_user, :change_registrant_user?
    if params[:registrant_id].present? && params[:user_id].present?
      user_id = params[:user_id]
      registrant = Registrant.find(params[:registrant_id])
      user = User.find(user_id)
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

  def bag_labels
    authorize current_user, :registrant_information?
    @registrants = Registrant.includes(:contact_detail).reorder(:sorted_last_name, :first_name).active.all

    names = []
    @registrants.each do |reg|
      names << "\n <b>##{reg.bib_number}</b> #{reg.last_name}, #{reg.first_name} \n #{reg.state_or_country(@config.usa?)} \n #{reg.registrant_type.capitalize}"
    end

    labels = Prawn::Labels.render(names, type: "Avery5160") do |pdf, name|
      set_font(pdf)

      pdf.text name, align: :center, size: 12, inline_format: true
    end

    send_data labels, filename: "bag-labels-#{Date.today}.pdf", type: "application/pdf"
  end

  # GET /registrants/show_all.pdf
  def show_all
    authorize current_user, :registrant_information?
    report = Report.create!(report_type: "registration_summary")
    ShowAllRegistrantsPdfJob.perform_later(report.id, params[:order], params[:offset], params[:max], current_user)

    redirect_to reports_path, notice: "Report Generation started. Check back in a few minutes"
  end

  private

  def set_registrants_breadcrumb
    add_breadcrumb "Manage Registrants", manage_one_registrants_path
  end

  def load_registrant
    @registrant = Registrant.find_by!(bib_number: params[:id])
  end
end
