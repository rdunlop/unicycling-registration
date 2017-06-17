# == Schema Information
#
# Table name: judges
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  judge_type_id  :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  status         :string           default("active"), not null
#
# Indexes
#
#  index_judges_event_category_id                                (competition_id)
#  index_judges_judge_type_id                                    (judge_type_id)
#  index_judges_on_judge_type_id_and_competition_id_and_user_id  (judge_type_id,competition_id,user_id) UNIQUE
#  index_judges_user_id                                          (user_id)
#

class JudgesController < ApplicationController
  layout "competition_management"
  before_action :authenticate_user!
  before_action :load_competition, only: %i[index create destroy copy_judges]

  # POST /competitions/#/judges
  # POST /competitions/#/judges.json
  def create
    @judge = @competition.judges.build(judge_params)
    authorize @judge
    if @judge.save
      flash[:notice] = 'Association was successfully created.'
      redirect_to competition_judges_path(@competition)
    else
      index
      render :index
    end
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

  # this is used to toggle the active-status of a judge
  def toggle_status
    @judge = Judge.find(params[:id])
    authorize @judge

    if @judge.active?
      @judge.update_attribute(:status, "removed")
    else
      @judge.update_attribute(:status, "active")
    end
    redirect_back(fallback_location: result_competition_path(@judge.competition))
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
    authorize @competition.judges.build, :index?

    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage Judges", competition_judges_path(@competition)

    @judge_types = JudgeType.order(:name).where(event_class: @competition.uses_judges)
    @all_data_entry_volunteers = User.this_tenant.data_entry_volunteer

    @judges = @competition.judges
    @competitions_with_judges = Competition.event_order.select{ |comp| comp.uses_judges } - [@competition]
    @judge ||= @competition.judges.build
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def judge_params
    params.require(:judge).permit(:judge_type_id, :user_id)
  end
end
