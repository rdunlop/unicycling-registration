class StreetScoresController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_competition, :except => [:destroy]

  def load_competition
    @judge = Judge.find(params[:judge_id])
    @competition = @judge.competition
    @street_scores = @judge.scores.sort {|a, b| b.val_1 <=> a.val_1 }
  end

  def index
    @score = @judge.scores.new
    @competitors = @competition.competitors
    authorize! :create, @score
  end

  def create
    @score = Score.new
    authorize! :create, @score
    if params[:competitor_id].present?
      c = @competition.competitors.find(params[:competitor_id])
      @score.competitor = c
    end
    @score.judge = @judge
    @score.val_1 = params[:points]
    @score.val_2 = 0
    @score.val_3 = 0
    @score.val_4 = 0

    respond_to do |format|
      if @score.save
        format.html { redirect_to judge_street_scores_path(@judge), notice: 'Score was successfully created.' }
        format.json { render json: @score, status: :created, location: @score }
      else
        @competitors = @competition.competitors
        format.html { render action: "index" }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @score = Score.find(params[:id])
    @judge = @score.judge
    authorize! :destroy, @score

    @score.destroy

    respond_to do |format|
      format.html { redirect_to judge_street_scores_path(@judge) }
      format.json { head :no_content }
    end
  end
end
