class DistanceAttemptsController < ApplicationController
  load_resource :judge, except: [:list, :destroy]
  load_and_authorize_resource through: :judge, except: [:list, :destroy]
  load_and_authorize_resource only: [:destroy]
  before_action :load_competition, :except => [:list, :destroy]

  before_action :set_judge_breadcrumb, except: [:list, :destroy]

  respond_to :html
  # feature "check competitor status"
  # "attempt", which updates the table, including the competitor status (if single/double-fault)
  # link to the competitor's history (which shows all of their attempts/faults)

  def index
    # show the current attempts, and a button which says "add new attempt"
    # display a summary of the most recent attempts, add to this list. (including competitor statuses)
    @recent_distance_attempts = @distance_attempts.includes(:competitor).limit(20)
    @max_distance_attempts = @competition.top_distance_attempts(5)

    @height = params[:height]
    # display the form which allows entering the distance, competitor, fault.
    @distance_attempt ||= DistanceAttempt.new(distance: @height)
  end

  def create
    @distance_attempt.judge = @judge
    respond_to do |format|
      if @distance_attempt.save
        format.html {
          flash[:notice] = 'Distance Attempt was successfully created.'
          redirect_to :back
        }
        format.js { }
      else
        format.html {
          @distance_attempts = @judge.distance_attempts
          index
          render "index"
        }
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
    params.require(:distance_attempt).permit(:distance, :fault, :registrant_id)
  end

  def load_competition
    @competition = @judge.competition
  end

  def set_judge_breadcrumb
    add_to_competition_breadcrumb(@judge.competition)
    add_breadcrumb @judge
  end
end
