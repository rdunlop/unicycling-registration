# == Schema Information
#
# Table name: time_results
#
#  id                  :integer          not null, primary key
#  competitor_id       :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string(255)      not null
#  comments            :text
#  comments_by         :string(255)
#  number_of_penalties :integer
#  entered_at          :datetime         not null
#  entered_by_id       :integer          not null
#  preliminary         :boolean
#  heat_lane_result_id :integer
#
# Indexes
#
#  index_time_results_on_competitor_id        (competitor_id)
#  index_time_results_on_heat_lane_result_id  (heat_lane_result_id) UNIQUE
#

class TimeResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition, except: [:edit, :destroy, :update]
  before_action :load_time_result, only: [:edit, :update, :destroy]
  before_action :authorize_data_entry, except: [:index]

  before_action :set_breadcrumbs, only: :index

  # XXX look into https://github.com/railscasts/396-importing-csv-and-excel/blob/master/store-with-validations/app/models/product_import.rb ??

  # GET competitions/1/time_results
  def index
    authorize @competition, :view_result_data?
    add_breadcrumb "Time Results"
    # @time_results = @competition.time_results.includes(:competitor => [:competition]) # XXX
    @time_result = TimeResult.new # @event.time_results.build
    @time_results = @competition.time_results

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /time_results/1/edit
  def edit
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Edit Time Result"
  end

  # POST event/1/time_results
  # POST event/1/time_results.json
  def create
    @time_result = TimeResult.new(time_result_params)
    respond_to do |format|
      @time_result.entered_by = current_user
      @time_result.entered_at = DateTime.now
      if @time_result.save
        format.html { redirect_to(competition_time_results_path(@time_result.competition), notice: 'Time result was successfully created.') }
        format.json { render json: @time_result, status: :created, location: @time_result.event }
      else
        @time_results = @competition.time_results
        format.html { render action: "index" }
        format.json { render json: @time_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT time_results/1
  # PUT time_results/1.json
  def update
    respond_to do |format|
      if @time_result.update_attributes(time_result_params)
        format.html { redirect_to(competition_time_results_path(@competition), notice: 'Time result was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @time_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE time_results/1
  # DELETE time_results/1.json
  def destroy
    @time_result.destroy

    respond_to do |format|
      format.html { redirect_to competition_time_results_path(@competition) }
      format.json { head :ok }
    end
  end

  private

  def authorize_data_entry
    authorize @competition, :modify_result_data?
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_time_result
    @time_result = TimeResult.find(params[:id])
    @competition = @time_result.competition
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end

  def time_result_params
    params.require(:time_result).permit(:number_of_laps, :comments, :comments_by, :status, :facade_hours, :facade_minutes, :seconds, :facade_hundreds, :thousands, :competitor_id)
  end
end
