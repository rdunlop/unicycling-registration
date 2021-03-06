class WavesController < ApplicationController
  include WaveBestTimeEagerLoader
  before_action :authenticate_user!
  before_action :load_competition
  before_action :authorize_competition

  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/waves
  def index
    add_breadcrumb "Current Waves"
    @competitors = eager_load_competitors_relations(@competition.competitors)
  end

  private

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def authorize_competition
    authorize @competition, :heat_recording?
  end
end
