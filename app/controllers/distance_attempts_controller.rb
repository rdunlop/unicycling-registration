class DistanceAttemptsController < ApplicationController
  load_and_authorize_resource
  before_filter :load_event_category, :except => [:destroy]

  def load_event_category
    unless params[:competitor_id].nil?
      @competitor = Competitor.find(params[:competitor_id])
      @judge = Judge.find(params[:judge_id])
      @event_category = @judge.event_category
      @distance_attempts = @competitor.distance_attempts
    else
      @judge = Judge.find(params[:judge_id])
      @event_category = @judge.event_category
      @distance_attempts = @event_category.distance_attempts
    end
  end

  def index
    @max_distance_attempts = @event_category.top_distance_attempts(10)
    # if the event_id is specified, I'm looking at /event/#event_id#/competitor/#id#/distance_attempts
    unless params[:external_id].nil?
        @reg = Registrant.where(:bib_number => params[:external_id]).first
        unless @reg.nil?
            @competitor = @reg.competitors.where(:event_category_id => @event_category.id).first
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
    @distance_attempt = DistanceAttempt.new
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
end
