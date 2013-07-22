class JudgesController < ApplicationController
  load_and_authorize_resource

  before_filter :load_competition, :only => [:index, :new, :create, :destroy, :copy_judges, :create_normal]

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def new # are there tests for this?
    @judge_types = JudgeType.where(:event_class => @competition.event.event_class)
    @all_judges = User.with_role(:judge).order(:email)
  end

  # POST /competitions/#/judges
  # POST /competitions/#/judges.json
  def create
    @judge.competition = @competition

    respond_to do |format|
      if @judge.save
        format.html { redirect_to competition_judges_path(@competition), notice: 'Association was successfully created.' }
        format.json { render json: @judge, status: :created, location: @judge }
      else
        index # call new function (above), to load the correct variables
        format.html { render action: "index" }
        format.json { render json: @judge.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /event/#/judges/copy_judges
  def copy_judges
    @from_event = Competition.find(params[:copy_judges][:competition_id])
    @from_event.judges.each do |source_judge|
        new_judge = @competition.judges.build
        new_judge.judge_type = source_judge.judge_type
        new_judge.user = source_judge.user
        new_judge.save!
    end

    redirect_to competition_judges_path(@competition), notice: "Copied Judges"
  end

  # this is used to update standard_execution_scores
  # PUT /judge/1
  def update

    respond_to do |format|
      if @judge.update_attributes(params[:judge])
        format.html { redirect_to judge_standard_scores_path(@judge), notice: 'Judge Scores successfully created.' }
      else
        new # call new function (above), to load the correct variables
        format.html { render action: "standard_scores/new" }
      end
    end
  end

  # DELETE /judges/1
  # DELETE /judges/1.json
  def destroy
    ec = @judge.competition

    respond_to do |format|
      if @judge.destroy
        format.html { redirect_to competition_judges_path(ec), notice: "Judge Destroyed" }
        format.json { head :no_content }
      else
        flash[:alert] = "Unable to destroy judge"
        format.html { redirect_to competition_judges_path(ec) }
        format.json { head :no_content }
      end
    end
  end

  def index
    new # load judge_types and all_judges
    @judges = @competition.judges
    @events = Event.all
    @judge ||= Judge.new
  end

  def create_normal
    @user = User.find(params[:judge][:user_id])
    respond_to do |format|
      if @user.add_role(:judge)
        format.html { redirect_to competition_judges_path(@competition), notice: 'Judge successfully created.' }
      else
        format.html { redirect_to competition_judges_path(@competiton), notice: 'Unable to add judge role to user.' }
      end
    end
  end

  def chiefs
    @events = Event.all
  end

  def create_chief
    ev = Event.find(params[:event_id])
    user = User.find(params[:user_id])
    user.add_role(:chief_judge, ev)

    redirect_to chiefs_judges_path, notice: 'Created Chief Judge'
  end
    
end
