require 'upload'
class ImportResultsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_user, :only => [:index, :create, :import_csv, :import_lif, :publish_to_competition, :destroy_all]

  def load_user
    @user = User.find(params[:user_id])
  end

  # GET /import_results
  # GET /import_results.json
  def index
    @import_results = @user.import_results.all
    @import_result = ImportResult.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @import_results }
    end
  end

  # GET /import_results/1
  # GET /import_results/1.json
  def show
    @import_result = ImportResult.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @import_result }
    end
  end

  # GET /import_results/1/edit
  def edit
    @import_result = ImportResult.find(params[:id])
  end

  # POST /import_results
  # POST /import_results.json
  def create
    @import_result = ImportResult.new(params[:import_result])
    @import_result.user = @user

    respond_to do |format|
      if @import_result.save
        format.html { redirect_to user_import_results_path(@user), notice: 'Import result was successfully created.' }
      else
        @import_results = @user.import_results
        format.html { render action: "index" }
      end
    end
  end

  # PUT /import_results/1
  # PUT /import_results/1.json
  def update
    @import_result = ImportResult.find(params[:id])

    respond_to do |format|
      if @import_result.update_attributes(params[:import_result])
        format.html { redirect_to user_import_results_path(@import_result.user), notice: 'Import result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @import_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /import_results/1
  # DELETE /import_results/1.json
  def destroy
    @import_result = ImportResult.find(params[:id])
    user = @import_result.user
    @import_result.destroy

    respond_to do |format|
      format.html { redirect_to user_import_results_path(user) }
      format.json { head :no_content }
    end
  end


  # POST /users/#/import_results/import_csv
  def import_csv
    upload = Upload.new
    comp = Competition.find(params[:competition_id])
    # FOR EXCEL DATA:
    raw_data = upload.extract_csv(params[:file])
    n = 0
    err = 0
    raw_data.each do |raw|
      result = @user.import_results.build
      result.raw_data = upload.convert_array_to_string(raw)
      result.comp = comp
      result.bib_number = raw[0]
      result.minutes = raw[1]
      result.seconds = raw[2]
      result.thousands = raw[3]
      result.disqualified = (raw[4] == "DQ")
      if result.save
        n = n + 1
      else
        err = err + 1
      end
    end
    redirect_to user_import_results_path(@user), notice: "#{n} rows added, and #{err} errors"
  end

  # FOR LIF (track racing) data:
  # GET /users/#/import_results/import_lif
  def import_lif
    upload = Upload.new
    raw_data = upload.extract_csv(params[:file])
    comp = Competition.find(params[:competition_id])
    heat = params[:heat]
    n = 0
    err = 0
    raw_data.shift #drop header row
    raw_data.each do |raw|
      lif_hash = upload.convert_lif_to_hash(raw)
      lane = lif_hash[:lane]
      id = get_id_from_lane_assignment(comp, heat, lane)

      result = @user.import_results.build
      result.raw_data = upload.convert_array_to_string(raw)
      result.competition = comp
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
    redirect_to user_import_results_path(@user), notice: "#{n} rows added, and #{err} errors"
  end

  def destroy_all
    @user.import_results.destroy_all
    redirect_to user_import_results_path(@user)
  end

  # POST /competitions/#/publish_to_competition
  def publish_to_competition
    import_results = @user.import_results

    @competition = nil
    n = 0
    err = 0
    import_results.each do |ir|
      tr = TimeResult.new
      competition = ir.competition
      @competition = competition

      id = ir.bib_number

      comp = competition.find_competitor_with_bib_number(id)
      if comp.nil?
        comp = competition.competitors.build
        member = comp.members.build
        member.registrant = Registrant.find_by_bib_number(id)
        if !member.valid?
          member.errors.each do |err|
            puts "mem erro: #{err}"
            err += 1
          end
        end
        if !comp.save
          comp.errors.each do |err|
            puts "error creating competitor because: #{err}"
            err += 1
          end
        end
      end
      tr.minutes = ir.minutes
      tr.seconds = ir.seconds
      tr.thousands = ir.thousands
      tr.disqualified = ir.disqualified
      tr.competitor = comp
      if tr.save
        n += 1
      else
        tr.errors.each do |err|
          puts "ERRO: #{err}"
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to competition_time_results_path(@competition), notice: "Added #{n} rows to #{@competition}. #{err} errors" }
    end
  end

  private 
  def get_id_from_lane_assignment(comp, heat, lane)
    la = LaneAssignment.find_by_competition_id_and_heat_and_lane(comp.id, heat, lane)
    if la.nil?
      id = nil
    else
      id = la.registrant.bib_number
    end
    id
  end
end

