class StandardScoresController < ApplicationController
  before_action :authenticate_user!

  before_action :find_judge
  before_action :find_competitor, except: [:index]

  # GET /judges/29/standard_scores
  def index
    @competitors = @judge.competitors
    @competitors.each do |c|
      authorize! :read, c
    end

    respond_to do |format|
      format.html
    end
  end

  # GET /judges/29/competitors/4/new
  def new
    @skills = @competitor.registrants.first.standard_skill_routine.standard_skill_routine_entries
    existing_scores =            @judge.standard_execution_scores.where(competitor_id: @competitor.id)
    existing_difficulty_scores = @judge.standard_difficulty_scores.where(competitor_id: @competitor.id)

    existing_scores.each do |s|
      authorize! :read, s
    end
    @skills.each do |skill|
      existing_score = existing_scores.find_by_standard_skill_routine_entry_id(skill.id)
      if existing_score.nil?
        new_score = @competitor.standard_execution_scores.create()
        new_score.standard_skill_routine_entry = skill
        new_score.judge = @judge
        new_score.wave = 0
        new_score.line = 0
        new_score.cross = 0
        new_score.circle = 0
        new_score.save!
      end
    end

    existing_difficulty_scores.each do |s|
      authorize! :read, s
    end
    @skills.each do |skill|
      existing_score = existing_difficulty_scores.find_by_standard_skill_routine_entry_id(skill.id)
      if existing_score.nil?
        new_score = @competitor.standard_difficulty_scores.create()
        new_score.standard_skill_routine_entry = skill
        new_score.judge = @judge
        new_score.devaluation = 0
        new_score.save!
      end
    end
  end

  private

  def find_judge
    @judge = Judge.find(params[:judge_id])
  end

  def find_competitor
    @competitor = Competitor.find(params[:competitor_id])
  end
end
