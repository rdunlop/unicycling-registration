class JudgesController < ApplicationController
  load_and_authorize_resource :competition, :only => [:index, :create, :destroy, :copy_judges, :create_normal, :create_race_official]
  before_filter :load_new_judge, :only => [:create]
  load_and_authorize_resource

  respond_to :html

  def load_new_judge
    @judge = @competition.judges.new(judge_params)
  end

  # POST /competitions/#/judges
  # POST /competitions/#/judges.json
  def create
    if @judge.save
      flash[:notice] = 'Association was successfully created.'
    else
      index
    end
    respond_with(@judge, location: competition_judges_path(@competition), action: "index")
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
      if @judge.update_attributes(judge_params)
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
    @judge_types = JudgeType.where(:event_class => @competition.event_class)
    @all_judges = User.with_role(:judge).order(:email)
    @race_officials = User.with_role(:race_official).order(:email)

    @judges = @competition.judges
    @events = Event.all
    @judge ||= Judge.new
  end

  def create_race_official
    @user = User.find(params[:judge][:user_id])
    respond_to do |format|
      if @user.add_role(:race_official)
        format.html { redirect_to competition_judges_path(@competition), notice: 'Race Official successfully created.' }
      else
        format.html { redirect_to competition_judges_path(@competiton), alert: 'Unable to add Race Official role to user.' }
      end
    end
  end

  def create_normal
    @user = User.find(params[:judge][:user_id])
    respond_to do |format|
      if @user.add_role(:judge)
        format.html { redirect_to competition_judges_path(@competition), notice: 'Judge successfully created.' }
      else
        format.html { redirect_to competition_judges_path(@competiton), alert: 'Unable to add judge role to user.' }
      end
    end
  end

  def chiefs
    @events = Event.all
  end

  private
  def judge_params
    params.require(:judge).permit(:judge_type_id, :user_id, :standard_execution_scores_attributes, :standard_difficulty_scores_attributes)
  end
end
