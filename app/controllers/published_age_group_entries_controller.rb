class PublishedAgeGroupEntriesController < ApplicationController
  before_filter :authenticate_user!, except: :show

  before_action :load_competition

  load_and_authorize_resource only: :show

  respond_to :html

  def show
    @ag_entry = @published_age_group_entry.age_group_entry
    @results_list = @competition.results_list_for(@ag_entry)

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf(name, "Portrait", attachment) }
    end
  end

  def preview
    authorize! :preview, AgeGroupEntry
    @ag_entry = AgeGroupEntry.find(params[:id])
    @results_list = @competition.results_list_for(@ag_entry)
    render :show
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end
end
