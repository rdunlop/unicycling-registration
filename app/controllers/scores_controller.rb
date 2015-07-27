class ScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :load_judge
  before_action :find_competitor, except: [:index]
  before_action :find_or_create_score, only: [:create, :new] # must be performed before load_and_auth_resource

  before_action :set_judge_breadcrumb

  # GET /judges/1/scores
  def index
    authorize @judge, :view_scores?

    if @judge.judge_type.name == "Presentation"
      render :new_presentation
    else
      render :index
    end
  end

  def new_presentation
    authorize @judge, :create_scores?
    add_breadcrumb "Set Score"

    @judging_form = JudgingForm.build_from_competitor_judge(@competitor, @judge)

    @judging_form.prepopulate!
  end

  # POST /judges/1/competitors/2/presentation_scores
  def create_presentation
    @judging_form = JudgingForm.build_from_competitor_judge(@competitor, @judge)
    authorize @judging_form.model[:score], :create?

    if @judging_form.validate(params[:score])
      @judging_form.save do |hash|
        dismount_score = @judging_form.model[:dismount_score]
        dismount_score.assign_attributes(hash[:dismount_score])
        dismount_score.save

        presentation_score = @judging_form.model[:score]
        presentation_score.assign_attributes(hash[:score])
        presentation_score.save
      end
      redirect_to judge_scores_path(@judge), notice: 'Score was successfully created.'
    else
      set_judge_breadcrumb
      render action: 'new_presentation'
      return
    end
  end

  # GET /judges/1/competitors/2/scores/new
  def new
    authorize @judge, :create_scores?
    add_breadcrumb "Set Score"

    respond_to do |format|
      format.html
    end
  end

  # POST /judges/1/competitors/2/scores
  def create
    authorize @score, :create?

    respond_to do |format|
      if @score.save
        format.html { redirect_to judge_scores_path(@judge), notice: 'Score was successfully created.' }
        format.json { render json: @score, status: :created, location: @score }
      else
        set_judge_breadcrumb
        format.html { render action: "new" }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def load_judge
    @judge = Judge.find(params[:judge_id])
  end

  def find_competitor
    @competitor = Competitor.find_by_id(params[:competitor_id])
  end

  def score_params
    params.require(:score).permit(:val_1, :val_2, :val_3, :val_4, :notes)
  end

  def boundary_score_params
    params.require(:boundary_score).permit(:number_of_people, :major_dismount, :medium_dismount, :minor_dismount, :major_boundary, :minor_boundary)
  end

  def set_judge_breadcrumb
    add_to_judge_breadcrumb(@judge)
  end

  def find_or_create_score
    @score = @competitor.scores.where(judge: @judge).first

    unless @score
      @score = @competitor.scores.new
      @score.judge = @judge
    end
    @score.assign_attributes(score_params) if params[:score]
  end
end
