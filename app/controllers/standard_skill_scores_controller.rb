# == Schema Information
#
# Table name: standard_skill_scores
#
#  id            :integer          not null, primary key
#  competitor_id :integer          not null
#  judge_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_standard_skill_scores_on_competitor_id               (competitor_id)
#  index_standard_skill_scores_on_judge_id_and_competitor_id  (judge_id,competitor_id)
#

class StandardSkillScoresController < ApplicationController
  before_action :authenticate_user!

  before_action :find_judge
  before_action :find_competitor, except: [:index]
  before_action :authorize_user
  before_action :add_breadcrumbs

  # GET /judges/29/standard_skill_scores
  def index
    @competitors = @judge.competitors

    respond_to do |format|
      format.html
    end
  end

  # GET /judges/29/competitors/4/standard_skill_scores/new
  def new
    skills = @competitor.registrants.first.standard_skill_routine.standard_skill_routine_entries.order(:position)
    @standard_skill_score = StandardSkillScore.new
    skills.each do |skill|
      @standard_skill_score.standard_skill_score_entries.build(standard_skill_routine_entry: skill)
    end
  end

  # POST /judges/29/competitors/4/standard_skill_score
  def create
    @standard_skill_score = StandardSkillScore.new(standard_skill_score_params)
    @standard_skill_score.competitor = @competitor
    @standard_skill_score.judge = @judge
    if @standard_skill_score.save
      redirect_to judge_standard_skill_scores_path(@judge), notice: "Standard Skill Score Saved"
    else
      flash.now[:alert] = "Error saving standard Skill score"
      render :new
    end
  end

  def edit
    @standard_skill_score = StandardSkillScore.find(params[:id])
  end

  # this is used to update standard_skill_score_entries
  # PUT /judges/29/competitors/4/standard_skill_score/1
  def update
    @standard_skill_score = StandardSkillScore.find(params[:id])

    if @standard_skill_score.update_attributes(standard_skill_score_params)
      redirect_to judge_standard_skill_scores_path(@judge), notice: 'Standard Skill Scores successfully updated.'
    else
      render :edit
    end
  end

  private

  def add_breadcrumbs
    add_competition_breadcrumb(@judge.competition)
  end

  def authorize_user
    authorize current_user, :under_development?
  end

  def find_judge
    @judge = Judge.find(params[:judge_id])
  end

  def find_competitor
    @competitor = Competitor.find(params[:competitor_id])
  end

  def standard_skill_score_params
    params.require(:standard_skill_score).permit(standard_skill_score_entries_attributes: [
                                                   :id, :standard_skill_routine_entry_id, :difficulty_devaluation_percent, :wave, :line, :cross, :circle]
                                                )
  end
end
