class DistanceAttemptsController < ApplicationController
  load_resource :judge, only: [:index, :create, :competitor_details]
  load_and_authorize_resource through: :judge, only: [:index, :create]
  load_and_authorize_resource only: [:destroy]
  before_action :load_competition, only: [:index, :create]
  skip_authorization_check only: :competitor_details
  before_action :load_new_distance_attempt, only: [:index, :competitor_details]

  before_action :set_judge_breadcrumb, only: [:index, :create]

  respond_to :html
  # feature "check competitor status"
  # "attempt", which updates the table, including the competitor status (if single/double-fault)
  # link to the competitor's history (which shows all of their attempts/faults)

  def load_new_distance_attempt
    @height = params[:height]
    # display the form which allows entering the distance, competitor, fault.
    @distance_attempt ||= DistanceAttempt.new(distance: @height)
  end

  def index
    # show the current attempts, and a button which says "add new attempt"
    @recent_distance_attempts = @distance_attempts.includes(:competitor).limit(20)
  end

  # Retrieve the details for a competitor
  # GET /judges/:judge_id/distance_attempts/competitor_details
  def competitor_details
    @competitor = Competitor.find(params[:competitor_id])
    @competition = @competitor.competition
    @distance_attempt.competitor = @competitor
    respond_to do |format|
      # display a summary of the most recent attempts, add to this list. (including competitor statuses)
      format.js
    end
  end

  def create
    @distance_attempt.judge = @judge
    respond_to do |format|
      if @distance_attempt.save
        @competitor = @distance_attempt.competitor
        format.html do
          flash[:notice] = 'Distance Attempt was successfully created.'
          redirect_to :back
        end
        format.js { }
      else
        format.html do
          @distance_attempts = @judge.distance_attempts
          index
          render "index"
        end
        format.js {}
      end
    end
    # respond_with(@distance_attempt, location: judge_distance_attempts_path(@judge, height: @distance_attempt.distance), action: "index")
  end

  def destroy
    @distance_attempt.destroy

    redirect_to :back
  end

  # /competitions/#/distance_attempts/list
  def list
    @competition = Competition.find(params[:competition_id])
    authorize! :list, DistanceAttempt
    @distance_attempts = @competition.distance_attempts.includes(:competitor)
    respond_to do |format|
      format.html { render action: "list" }
      format.json { head :no_content }
    end
  end

  private

  def distance_attempt_params
    params.require(:distance_attempt).permit(:distance, :fault, :registrant_id, :competitor_id)
  end

  def load_competition
    @competition = @judge.competition
  end

  def set_judge_breadcrumb
    add_to_competition_breadcrumb(@judge.competition)
    add_breadcrumb @judge
  end
end
