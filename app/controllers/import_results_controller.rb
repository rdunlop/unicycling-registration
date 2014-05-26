require 'upload'
class ImportResultsController < ApplicationController
  before_filter :authenticate_user!
  before_action :load_user, except: [:show, :edit, :update, :destroy]
  before_action :load_competition, except: [:show, :edit, :update, :destroy]
  before_filter :load_new_import_result, :only => [:create]
  before_action :load_import_results, :only => [:data_entry, :index]
  load_and_authorize_resource

  before_action :set_breadcrumbs

  # GET /users/#/import_results
  # GET /users/#/import_results.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @import_results }
    end
  end

  # GET /import_results/1
  # GET /import_results/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @import_result }
    end
  end

  # GET /import_results/1/edit
  def edit
    add_breadcrumb "Edit Imported Result"
  end

  # POST /users/#/competitions/#/import_results
  # POST /users/#/competitions/#/import_results.json
  def create

    respond_to do |format|
      if @import_result.save
        format.html { redirect_to data_entry_user_competition_import_results_path(@user, @competition), notice: 'Import result was successfully created.' }
        format.js { }
      else
        @import_results = @user.import_results
        format.html { render action: "data_entry" }
        format.js { }
      end
    end
  end

  # PUT /import_results/1
  # PUT /import_results/1.json
  def update

    respond_to do |format|
      if @import_result.update_attributes(import_result_params)
        format.html { redirect_to user_competition_import_results_path(@import_result.user, @import_result.competition), notice: 'Import result was successfully updated.' }
        format.json { head :no_content }
        format.js { }
      else
        format.html { render action: "edit" }
        format.json { render json: @import_result.errors, status: :unprocessable_entity }
        format.js { }
      end
    end
  end

  # DELETE /import_results/1
  # DELETE /import_results/1.json
  def destroy
    user = @import_result.user
    competition = @import_result.competition
    @import_result.destroy

    respond_to do |format|
      format.html { redirect_to user_competition_import_results_path(user, competition) }
      format.json { head :no_content }
    end
  end

  def data_entry
    add_breadcrumb "Enter Single Data"

    @is_start_time = params[:is_start_times] || false
    @import_result = ImportResult.new
    @import_result.is_start_time = @is_start_time

    @import_results = @import_results.where(is_start_time: @is_start_time)
  end

  def display_csv
    add_breadcrumb "Import CSV"
  end

  # POST /users/#/competitions/#/import_results/import_csv
  def import_csv
    upload = Upload.new
    is_start_time = params[:start_times] || false
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(params[:file])
    n = 0
    err = 0
    raw_data.each do |raw|
      raw_data = upload.convert_array_to_string(raw)
      result = @competition.build_import_result_from_raw(raw)
      result.raw_data = raw_data
      result.user = @user
      result.competition = @competition
      result.is_start_time = is_start_time
      if result.save
        n = n + 1
      else
        err = err + 1
      end
    end
    redirect_to user_competition_import_results_path(@user, @competition), notice: "#{n} rows added, and #{err} errors"
  end

  def display_lif
    add_breadcrumb "Import Lif (Heat Data)"
  end

  # FOR LIF (track racing) data:
  # GET /users/#/competitions/#/import_results/import_lif
  def import_lif
    upload = Upload.new
    raw_data = upload.extract_csv(params[:file])
    raise StandardError.new("Competition not set for lane assignments") unless @competition.uses_lane_assignments
    heat = params[:heat]
    n = 0
    err = 0
    raw_data.shift #drop header row
    raw_data.each do |raw|
      lif_hash = upload.convert_lif_to_hash(raw)
      lane = lif_hash[:lane]
      id = get_id_from_lane_assignment(@competition, heat, lane)

      result = @user.import_results.build
      result.raw_data = upload.convert_array_to_string(raw)
      result.competition = @competition
      result.bib_number = id
      result.minutes = lif_hash[:minutes]
      result.seconds = lif_hash[:seconds]
      result.thousands = lif_hash[:thousands]
      result.disqualified = (lif_hash[:disqualified] == "DQ")
      if result.save
        n = n + 1
      else
        err = err + 1
      end
    end
    redirect_to user_competition_import_results_path(@user, @competition), notice: "#{n} rows added, and #{err} errors"
  end

  # DELETE /users/#/competitions/#/import_results/destroy_all
  def destroy_all
    @user.import_results.where(:competition_id => @competition).destroy_all
    redirect_to user_competition_import_results_path(@user, @competition)
  end

  # POST /users/#/competitions/#/import_results/publish_to_competition
  def publish_to_competition
    import_results = @user.import_results.where(:competition_id => @competition)

    n = 0
    err_count = 0
    import_results.each do |ir|

      id = ir.bib_number

      competitor = @competition.find_competitor_with_bib_number(id)
      registrant = Registrant.find_by_bib_number(id)
      if competitor.nil?
        begin
          @competition.create_competitor_from_registrants([registrant], nil)
          competitor = @competition.find_competitor_with_bib_number(id)
        rescue Exception => ex
          puts "error creating competitor because: #{ex}"
          err_count += 1
        end
      end

      tr = @competition.build_result_from_imported(ir)
      tr.competitor = competitor
      if tr.save
        n += 1
      else
        tr.errors.each do |err|
          puts "ERRO: #{err}"
        end
        err_count += 1
      end
    end
    respond_to do |format|
      format.html { redirect_to results_url(@competition), notice: "Added #{n} rows to #{@competition}. #{err_count} errors" }
    end
  end

  private

  def import_result_params
    params.require(:import_result).permit(:bib_number, :disqualified, :minutes, :raw_data, :seconds, :thousands, :rank, :details, :is_start_time)
  end

  def get_id_from_lane_assignment(comp, heat, lane)
    la = LaneAssignment.find_by_competition_id_and_heat_and_lane(comp.id, heat, lane)
    if la.nil?
      id = nil
    else
      id = la.registrant.bib_number
    end
    id
  end

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_import_results
    @import_results = @user.import_results.where(competition_id: @competition)
  end

  def load_new_import_result
    @import_result = ImportResult.new(import_result_params)
    @import_result.user = @user
    @import_result.competition = @competition
  end

  def set_breadcrumbs
    @competition ||= @import_result.competition
    @user ||= @import_result.user
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Import Results (#{@user})", user_competition_import_results_path(@user, @competition)
  end
end

