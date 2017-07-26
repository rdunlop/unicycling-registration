class UploadedFilesController < ApplicationController
  before_action :load_competition
  before_action :authorize_access
  before_action :set_breadcrumbs

  def index
    @uploaded_files = @competition.uploaded_files.order(:created_at)
  end

  def show
    @uploaded_file = @competition.uploaded_files.find(params[:id])
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def authorize_access
    authorize @competition, :show?
  end

  def set_breadcrumbs
    add_competition_setup_breadcrumb
    add_breadcrumb @competition.to_s, competition_path(@competition)
    add_breadcrumb "Uploaded Files"
  end
end
