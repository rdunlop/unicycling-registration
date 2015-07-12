class JudgesController < ApplicationController
  layout "competition_management"
  before_action :load_competition, only: [:index, :create, :destroy, :copy_judges]

  respond_to :html

  # POST /competitions/#/judges
  # POST /competitions/#/judges.json
  def create
    @judge = @competition.judges.build(judge_params)
    authorize @judge
    if @judge.save
      flash[:notice] = 'Association was successfully created.'
    else
      index
    end
    respond_with(@judge, location: competition_judges_path(@competition), action: "index")
  end

  # POST /event/#/judges/copy_judges
  def copy_judges
    authorize @competition, :copy_judges?

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
    @judge = Judge.find(params[:id])
    authorize @judge

    respond_to do |format|
      if @judge.update_attributes(judge_params)
        format.html { redirect_to judge_standard_scores_path(@judge), notice: 'Judge Scores successfully created.' }
      else
        new # call new function (above), to load the correct variables
        format.html { render action: "standard_scores/new" }
      end
    end
  end

  # this is used to toggle the active-status of a judge
  def toggle_status
    authorize @judge

    if @judge.active?
      @judge.update_attribute(:status, "removed")
    else
      @judge.update_attribute(:status, "active")
    end
    redirect_to :back
  end

  # DELETE /judges/1
  # DELETE /judges/1.json
  def destroy
    @judge = @competition.judges.find(params[:id])
    authorize @judge

    respond_to do |format|
      if @judge.destroy
        format.html { redirect_to competition_judges_path(@competition), notice: "Judge Deleted" }
        format.json { head :no_content }
      else
        flash[:alert] = "Unable to delete judge"
        format.html { redirect_to competition_judges_path(@competition) }
        format.json { head :no_content }
      end
    end
  end

  def index
    authorize Judge.new, :index?

    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage Judges", competition_judges_path(@competition)

    @judge_types = JudgeType.order(:name).where(event_class: @competition.uses_judges)
    @all_data_entry_volunteers = User.with_role(:data_entry_volunteer).order(:email)

    @judges = @competition.judges
    @competitions_with_judges = Competition.event_order.select{ |comp| comp.uses_judges } - [@competition]
    @judge ||= @competition.judges.build
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def judge_params
    params.require(:judge).permit(:judge_type_id, :user_id, :standard_execution_scores_attributes, :standard_difficulty_scores_attributes)
  end
end
