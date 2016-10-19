class Compete::SignInsController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs
  before_action :load_competitors_by_order, only: [:show, :edit, :update]

  respond_to :html

  # GET /competitions/1/sign_ins
  def show
    add_breadcrumb "Sign-In Sheets"

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("show") }
    end
  end

  # GET /competitions/1/sign_ins/edit
  def edit
    add_breadcrumb "Enter Sign-In"
  end

  # PUT /competitions/1/sign_ins
  def update
    respond_to do |format|
      if @competition.update_attributes(update_competitors_params)
        flash[:notice] = 'Competitors successfully updated.'
        format.html { redirect_back(fallback_location: edit_competition_sign_ins_path(@competition)) }
      else
        edit
        format.html { render :edit }
      end
    end
  end

  private

  def load_competitors_by_order
    competitors = @competition.competitors.where(status: Competitor.sign_in_statuses.values)

    if @competition.start_list_present? && params[:sort] != "id"
      @competitors = competitors.reorder(:wave, :lowest_member_bib_number)
    else
      @competitors = competitors.reorder(:lowest_member_bib_number)
    end
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
    authorize @competition, :enter_sign_ins?
  end

  def update_competitors_params
    params.require(:competition).permit(competitors_attributes: [:id, :status, :wave, :geared, :riding_wheel_size, :riding_crank_size, :notes])
  end

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition)
  end
end
