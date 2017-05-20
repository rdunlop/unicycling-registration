class Admin::BibNumbersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_registrants_breadcrumb
  before_action :authorize_admin

  # GET /bib_numbers
  def index
  end

  def create
    registrant = Registrant.find(params[:registrant_id])
    new_bib_number = params[:new_bib_number]
    if new_bib_number.nil?
      flash[:alert] = "Please specify a new bib number"
      redirect_to bib_numbers_path
    elsif BibNumberUpdater.update_bib_number(registrant, new_bib_number)
      flash[:notice] = "Registrant #{registrant} set to #{new_bib_number}"
    else
      flash[:alert] = "Error setting bib number. Is it in range for the registrant-type?"
    end

    redirect_to bib_numbers_path
  end

  private

  def authorize_admin
    authorize current_user, :registrant_information?
  end

  def set_registrants_breadcrumb
    add_breadcrumb "Manage Registrants", manage_one_registrants_path
  end
end
