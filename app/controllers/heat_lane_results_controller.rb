class HeatLaneResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, only: [:create]
  before_action :load_heat_lane_result, except: [:create]

  before_action :authorize_competition_data

  before_action :set_breadcrumbs

  # GET /heat_lane_results/1/edit
  def edit
    add_breadcrumb "Edit Heat Lane Result"
  end

# PUT /heat_lane_results/1
  def update
    respond_to do |format|
      if @heat_lane_result.update_attributes(heat_lane_result_params)
        format.html { redirect_to data_entry_user_competition_import_results_path(@import_result.user, @import_result.competition, is_start_times: @import_result.is_start_time), notice: 'Import result was successfully updated.' }
        format.json { head :no_content }
        format.js { }
      else
        format.html { render action: "edit" }
        format.json { render json: @import_result.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  # POST /users/#/competitions/#/heat_lane_results
  # POST /users/#/competitions/#/heat_lane_results.json
  def create
    respond_to do |format|
      if @heat_lane_result.save
        format.html { redirect_to data_entry_user_competition_import_results_path(@user, @competition, is_start_times: @import_result.is_start_time), notice: 'Result was successfully created.' }
        format.js { }
      else
        format.html { render action: "data_entry" }
        format.js { }
      end
    end
  end

  # DELETE /heat_lane_results/1
  # DELETE /heat_lane_results/1.json
  def destroy
    @heat_lane_result.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  private

  def authorize_competition_data
    authorize @competition, :create_preliminary_result?
  end

  def load_heat_lane_result
    @heat_lane_result = HeatLaneResult.find(params[:id])
    @competition = @heat_lane_result.competition
  end

  def heat_lane_result_params
    params.require(:heat_lane_result).permit(:heat, :lane, :status, :minutes, :seconds, :thousands, :raw_data)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end
end
