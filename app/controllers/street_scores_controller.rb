class StreetScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, except: [:destroy]

  def index
    @score = @judge.scores.new
    @competitors = @competition.competitors.reorder(:position)
    authorize @judge, :view_scores?
  end

  # Put the competitor with id `id` at position `row_order_position`.
  #
  # id: 6568,
  # row_order_position: 4,
  # controller: street_scores,
  # action: update_order,
  # locale: en,
  # judge_id: 336,
  #
  def update_order
    @score = @judge.scores.find_by(competitor_id: params[:id])
    authorize @score, :create?
    # row_order_position is from '0', but must be from '1'
    set_competitor_rank_score(@score, params[:row_order_position].to_i + 1)
    @street_scores = @judge.reload.scores.sort {|a, b| a.val_1 <=> b.val_1 }
    respond_to do |format|
      format.js
    end
  end

  # Positions a competitor at the given rank, though it does not leave any
  # gaps in the numbers
  #
  # competitor_id: 1234,
  # rank: 4
  #
  def set_rank
    @score = find_or_build_score_for(params[:competitor_id])
    authorize @score, :create?
    if set_competitor_rank_score(@score, params[:rank].to_i - 1)
      flash[:notice] = "Ok"
    end
    @street_scores = @judge.reload.scores.sort {|a, b| a.val_1 <=> b.val_1 }
    respond_to do |format|
      format.js
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

  def set_competitor_rank_score(score_object, rank)
    Score.transaction do
      current_rank = 1
      scores_without_current_score = @street_scores.reject{ |s| s == score_object }

      # When moving a score up vs down, it changes the elements which we
      # want to move below us
      low_scores = scores_without_current_score.select do |s|
        if score_object.val_1.to_i < rank
          s.val_1 <= rank
        else
          s.val_1 < rank
        end
      end

      low_scores.each do |score|
        score.update(val_1: current_rank)
        current_rank += 1
      end
      score_object.update(val_1: current_rank)
      current_rank += 1

      high_scores = scores_without_current_score - low_scores
      high_scores.each do |score|
        score.update(val_1: current_rank)
        current_rank += 1
      end
    end

    true
  end

  def find_or_build_score_for(competitor_id)
    score = @judge.scores.where(competitor_id: competitor_id).first
    score ||= @judge.scores.build(competitor_id: competitor_id)
    score
  end

  def load_competition
    @judge = Judge.find(params[:judge_id])
    @competition = @judge.competition
    @street_scores = @judge.scores.sort {|a, b| a.val_1 <=> b.val_1 }
  end
end
