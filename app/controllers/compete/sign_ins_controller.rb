class Compete::SignInsController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/sign_ins
  def show
    authorize @competition, :show?
    add_breadcrumb "Sign-In Sheets"
    if @competition.start_list_present?
      @competitors = @competition.competitors.reorder(:wave, :lowest_member_bib_number)
    else
      @competitors = @competition.competitors.reorder(:lowest_member_bib_number)
    end

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("show") }
    end
  end

  # GET /competitions/1/sign_ins/edit
  def edit
    authorize @competition, :modify_result_data?
    add_breadcrumb "Enter Sign-In"
    @competitors = @competition.competitors.reorder(:lowest_member_bib_number)
  end

  # PUT /competitions/1/sign_ins
  def update
    authorize @competition, :modify_result_data?
    respond_to do |format|
      if @competition.update_attributes(update_competitors_params)
        flash[:notice] = 'Competitors successfully updated.'
        format.html { redirect_to :back }
      else
        edit
        format.html { render :edit }
      end
    end
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def update_competitors_params
    params.require(:competition).permit(competitors_attributes: [:id, :status, :wave, :geared, :riding_wheel_size, :riding_crank_size, :notes])
  end

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition)
  end
end
