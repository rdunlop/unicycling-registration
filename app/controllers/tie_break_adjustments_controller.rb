class TieBreakAdjustmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_judge, only: [:index, :create]
  before_action :load_tie_break_adjustment, only: [:destroy]

  respond_to :html

  # POST /judges/#/tie_break_adjustments
  def create
    authorize @judge, :can_judge?
    @tie_break_adjustment = TieBreakAdjustment.new(tie_break_adjustment_params)
    if @tie_break_adjustment.save
      flash[:notice] = 'Tie Break Adjustment was successfully created.'
    else
      @tie_break_adjustments = @judge.tie_break_adjustments
      index
    end
    respond_with(@tie_break_adjustment, location: judge_tie_break_adjustments_path(@judge), action: "index")
  end

  # DELETE /tie_break_adjustments/1
  def destroy
    authorize @judge, :can_judge?
    judge = @tie_break_adjustment.judge

    respond_to do |format|
      if @tie_break_adjustment.destroy
        format.html { redirect_to judge_tie_break_adjustments_path(judge), notice: "Adjustment Deleted" }
        format.json { head :no_content }
      else
        flash[:alert] = "Unable to delete adjustment"
        format.html { redirect_to judge_tie_break_adjustments_path(judge) }
        format.json { head :no_content }
      end
    end
  end

  def index
    authorize @judge, :can_judge?
    @tie_break_adjustments = @judge.tie_break_adjustments
    add_to_competition_breadcrumb(@judge.competition)
    add_breadcrumb "Distance Attempt Entry", judge_distance_attempts_path(@judge)
    add_breadcrumb "Add Tie Break Adjustments", judge_tie_break_adjustments_path(@judge)

    @tie_break_adjustment ||= TieBreakAdjustment.new
  end

  private

  def load_judge
    @judge = Judge.find(params[:judge_id])
  end

  def load_tie_break_adjustment
    @tie_break_adjustment = TieBreakAdjustment.find(params[:id])
  end

  def tie_break_adjustment_params
    params.require(:tie_break_adjustment).permit(:judge_id, :competitor_id, :tie_break_place)
  end
end
