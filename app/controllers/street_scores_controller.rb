class StreetScoresController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check
  before_filter :load_event_category, :except => [:destroy]

  def load_event_category
    @judge = Judge.find(params[:judge_id])
    @event_category = @judge.event_category
    @street_scores = @judge.street_scores.sort {|a, b| b.val_1 <=> a.val_1 }
  end

  def index
    @score = @judge.street_scores.new
    @competitors = @event_category.competitors
    authorize! :create, @score
  end

  def create
    @score = StreetScore.new
    authorize! :create, @score
    cid = params[:competitor_id]
    eid = params[:external_id]
    if ((!cid.empty?) && (!eid.empty?))
        # return an error if both comp and id are specified
        flash[:alert] = "unable to specify both ID and by competitor"
    else
      unless cid.empty?
        @event_category.competitors.each do |c|
          if c.id == cid.to_i
            @score.competitor = c
          end
        end
      end
      unless eid.empty?
        @event_category.competitors.each do |c|
          if c.external_id == eid
            @score.competitor = c
          end
        end
      end
    end
    @score.judge = @judge
    @score.val_1 = params[:score]

    respond_to do |format|
      if @score.save
        format.html { redirect_to judge_street_scores_path(@judge), notice: 'Score was successfully created.' }
        format.json { render json: @score, status: :created, location: @score }
      else
        @competitors = @event_category.competitors
        format.html { render action: "index" }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @score = StreetScore.find(params[:id])
    @judge = @score.judge
    authorize! :destroy, @score

    @score.destroy

    respond_to do |format|
      format.html { redirect_to judge_street_scores_path(@judge) }
      format.json { head :no_content }
    end
  end
end
