class DistanceAttemptsController < ApplicationController
  load_and_authorize_resource
  before_filter :load_event_category, :except => [:destroy]

  def load_event_category
    unless params[:competitor_id].nil?
      @competitor = Competitor.find(params[:competitor_id])
      @judge = Judge.find(params[:judge_id])
      @competition = @judge.competition
      @distance_attempts = @competitor.distance_attempts
    else
      @judge = Judge.find(params[:judge_id])
      @competition = @judge.competition
      @distance_attempts = @competition.distance_attempts
    end
  end

  def index
    @max_distance_attempts = @competition.top_distance_attempts(10)
    # if the event_id is specified, I'm looking at /event/#event_id#/competitor/#id#/distance_attempts
    unless params[:external_id].nil?
        @reg = Registrant.where(:bib_number => params[:external_id]).first
        unless @reg.nil?
            @competitor = @reg.competitors.where(:competition_id => @competition.id).first
            unless @competitor.nil?
                respond_to do |format|
                    format.html { redirect_to new_judge_competitor_distance_attempt_path(@judge, @competitor) }
                end
            else
                flash[:alert] = "That Registrant (#{params[:external_id]}) is not registered for this event"
            end
        else
            flash[:alert] = "Unable to find a Registrant with that ID (#{params[:external_id]})"
        end
    end
  end

  def new
  end

  def create
    @distance_attempt.competitor = @competitor
    @distance_attempt.judge = @judge

    respond_to do |format|
      if @distance_attempt.save
        format.html { redirect_to new_judge_competitor_distance_attempt_path(@judge, @competitor), notice: 'Distance Attempt was successfully created.' }
        format.json { render json: @score, status: :created, location: @score }
      else
        format.html { render action: "new" }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    judge = @distance_attempt.judge
    comp = @distance_attempt.competitor
    @distance_attempt.destroy

    respond_to do |format|
      format.html { redirect_to new_judge_competitor_distance_attempt_path(judge, comp) }
      format.json { head :no_content }
    end
  end

  def list

    respond_to do |format|
      format.html { render action: "list" }
      format.json { head :no_content }
    end
  end

  def set_places
    @calc = @competition.score_calculator(@competition)
    @calc.update_all_places
    redirect_to competition_distance_attempts_path(@competition), :notice => "All Places updated"
  end

  private
  def distance_attempt_params
    params.require(:distance_attempt).permit(:distance, :fault)
  end
end
