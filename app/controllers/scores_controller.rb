class ScoresController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :judge # requires that the current user is able to access the judge, thus hiding scores
  load_and_authorize_resource

  before_filter :find_judge
  before_filter :find_competitor, :except => [:index]

  def find_judge
    @judge = Judge.find_by_id(params[:judge_id])
  end

  def find_competitor
    @competitor = Competitor.find_by_id(params[:competitor_id])
  end

  # GET /judges/1/scores
  def index
    respond_to do |format|
        format.html
    end
  end

  # GET /judges/1/competitors/2/scores/new
  def new
    @score = @competitor.scores.new
    if @judge.judge_type.boundary_calculation_enabled
        @boundary_score = @competitor.boundary_scores.new
    end
    respond_to do |format|
        format.html
    end
  end

  # POST /judges/1/competitors/2/scores
  def create
    authorize! :create_scores, @competitor.competition

    @score.judge = @judge
    @score.competitor = @competitor

    if @judge.judge_type.boundary_calculation_enabled
        @boundary_score = BoundaryScore.new(boundary_score_params)
        @boundary_score.competitor = @competitor
        @boundary_score.judge = @judge
        if @boundary_score.valid?
            # boundary score is valid, save the result to the @score
            @score.val_1 = @boundary_score.total
        else
            respond_to do |format|
                # on fail to save, re-render new
                format.html { render action: "new" }
                format.json { render json: @score.errors, status: :unprocessable_entity }
            end
            return
        end
    end

    respond_to do |format|
      if @score.save
        if @judge.judge_type.boundary_calculation_enabled
            @boundary_score.save
        end
        format.html { redirect_to judge_scores_path(@judge), notice: 'Score was successfully created.' }
        format.json { render json: @score, status: :created, location: @score }
      else
        format.html { render action: "new" }
        format.json { render json: @score.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /judges/1/competitors/2/scores/1/edit
  def edit
    @judge = Judge.find(params[:judge_id])
    @boundary_score = BoundaryScore.find_by(competitor_id: params[:competitor_id], judge_id: params[:judge_id])
    respond_to do |format|
        format.html
        format.js
    end
  end

  # PUT /judges/1/competitors/2/scores/1
  # PUT /judges/1/competitors/2/scores/1.json
  def update
    authorize! :create_scores, @competitor.competition

    if @judge.judge_type.boundary_calculation_enabled
        @boundary_score = BoundaryScore.find_by(competitor_id: params[:competitor_id], judge_id: params[:judge_id])
        if @boundary_score.update_attributes(boundary_score_params)
            # boundary score is valid
            @score.val_1 = @boundary_score.total
        else
            respond_to do |format|
                # on fail to save, re-render new
                format.html { render action: "edit" }
                format.json { render json: @score.errors, status: :unprocessable_entity }
            end
            return
        end
    end

    respond_to do |format|
      if @score.update_attributes(score_params)
        format.html { redirect_to judge_scores_url(@judge), notice: 'Score was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @score.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  private
  def score_params
    params.require(:score).permit(:val_1, :val_2, :val_3, :val_4, :notes)
  end

  def boundary_score_params
    params.require(:boundary_score).permit(:number_of_people, :major_dismount, :medium_dismount, :minor_dismount, :major_boundary, :minor_boundary)
  end
end
