class JudgesController < ApplicationController
  load_and_authorize_resource

  before_filter :load_event_category, :only => [:index, :new, :create, :destroy, :copy_judges]

  def load_event_category
    @event_category = EventCategory.find(params[:event_category_id])
  end

  def new # are there tests for this?
    @judge_types = JudgeType.where(:event_class => @event_category.event.event_class)
    @all_judges = User.with_role(:judge).order(:email)
  end

  # POST /event_categories/#/judges
  # POST /event_categories/#/judges.json
  def create
    @judge.event_category = @event_category

    respond_to do |format|
      if @judge.save
        format.html { redirect_to new_event_category_judge_path(@event_category), notice: 'Association was successfully created.' }
        format.json { render json: @judge, status: :created, location: @judge }
      else
        new # call new function (above), to load the correct variables
        format.html { render action: "new" }
        format.json { render json: @judge.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /event/#/judges/copy_judges
  def copy_judges
    @from_event = EventCategory.find(params[:copy_judges][:event_category_id])
    @from_event.judges.each do |source_judge|
        new_judge = @event_category.judges.build
        new_judge.judge_type = source_judge.judge_type
        new_judge.user = source_judge.user
        new_judge.save!
    end

    redirect_to new_event_category_judge_path(@event_category), notice: "Copied Judges"
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
    ec = @judge.event_category
    @judge.destroy

    respond_to do |format|
      format.html { redirect_to new_event_category_judge_path(ec) }
      format.json { head :no_content }
    end
  end

  def index
    @all_judges = User.with_role(:judge)
    @judges = @event_category.judges
    @events = Event.all
    @judge = Judge.new
  end

  def create_normal
    @user = User.find(params[:judge][:user_id])
    respond_to do |format|
      if @user.add_role(:judge)
        format.html { redirect_to root_path, notice: 'Judge successfully created.' }
      else
        format.html { redirect_to root_path, notice: 'Unable to create Judge successfully created.' }
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
