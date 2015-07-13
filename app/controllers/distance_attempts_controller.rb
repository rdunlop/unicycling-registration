class DistanceAttemptsController < ApplicationController
  before_action :load_and_authorize_judge, only: [:index, :create, :new, :competitor_details]
  before_action :load_distance_attempt, only: [:destroy]

  before_action :load_competition, only: [:index, :create]
  before_action :skip_authorization, only: :competitor_details
  before_action :load_new_distance_attempt, only: [:index, :competitor_details]

  before_action :set_judge_breadcrumb, only: [:index, :create]

  respond_to :html
  # feature "check competitor status"
  # "attempt", which updates the table, including the competitor status (if single/double-fault)
  # link to the competitor's history (which shows all of their attempts/faults)

  def index
    @distance_attempts = @judge.distance_attempts
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
    @distance_attempt = DistanceAttempt.new(distance_attempt_params)
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
    authorize current_user, :view_data_entry_menu?
    @distance_attempts = @competition.distance_attempts.includes(:competitor)
    respond_to do |format|
      format.html { render action: "list" }
      format.json { head :no_content }
    end
  end

  private

  def load_and_authorize_judge
    @judge = Judge.find(params[:judge_id])
    authorize @judge, :can_judge?
  end

  def load_distance_attempt
    @distance_attempt = DistanceAttempt.find(params[:id])
  end

  def load_new_distance_attempt
    @height = params[:height]
    # display the form which allows entering the distance, competitor, fault.
    @distance_attempt ||= DistanceAttempt.new(distance: @height)
  end

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
