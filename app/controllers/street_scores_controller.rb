class StreetScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, except: [:destroy]

  def index
    @score = @judge.scores.new
    @competitors = @competition.competitors.reorder(:position)
    authorize @judge, :view_scores?
  end

  def update_score
    @score = @judge.scores.where(competitor_id: params[:competitor_id]).first
    @score ||= @judge.scores.build(competitor_id: params[:competitor_id])
    authorize @score, :create?
    if params[:score].present?
      @score.val_1 = params[:score]
      @score.val_2 = 0
      @score.val_3 = 0
      @score.val_4 = 9
      @score.save!
    else
      @score.destroy if @score.persisted?
    end

    respond_to do |format|
      format.js {}
    end
  end

  def destroy
    @score = Score.find(params[:id])
    @judge = @score.judge
    authorize @score, :destroy?

    @score.destroy

    respond_to do |format|
      format.html { redirect_to judge_street_scores_path(@judge) }
      format.json { head :no_content }
    end
  end

  private

  def load_competition
    @judge = Judge.find(params[:judge_id])
    @competition = @judge.competition
    @street_scores = @judge.scores.sort {|a, b| b.val_1 <=> a.val_1 }
  end
end
