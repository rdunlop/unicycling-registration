class WavesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :competition

  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/waves
  def index
    add_breadcrumb "Current Waves"
    @competitors = @competition.competitors
  end

  private

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end
