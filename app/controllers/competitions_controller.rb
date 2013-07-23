require 'csv'
require 'upload'
class CompetitionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_event, :only => [:index]
  before_filter :load_event_category, :only => [:create, :new]
  before_filter :load_competition, :only => [:sign_ups, :freestyle_scores, :lock, :get_import_time_results_competition, :confirm_import_time_results_competition, :import_time_results_competition]

  def load_event
    @event = Event.find(params[:event_id])
  end

  def load_competitions
    @competitions = @event.competitions
  end

  def load_event_category
    @event_category = EventCategory.find(params[:event_category_id])
  end

  def load_competition
    @competition = Competition.find(params[:id])
  end

  # /event_categories/#/competitions/new
  def new
  end

  # GET /competitions
  # GET /competitions.json
  def index
    load_competitions
    @competition = Competition.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @competitions }
    end
  end

  # GET /competitions/1
  # GET /competitions/1.json
  def show
    @competition = Competition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @competition }
    end
  end

  # GET /competitions/1/edit
  def edit
    @competition = Competition.find(params[:id])
  end

  # POST /event_categories/#/competitions
  # POST /event_categories/#/competitions.json
  def create
    @competition = Competition.new(params[:competition])
    @competition.event = @event_category.event

    @event_category.competition = @competition

    respond_to do |format|
      if @event_category.valid? and @competition.save
        @event_category.save
        message = "Competition was successfully created."

        message += @competition.create_competitors_from_registrants(@event_category.signed_up_registrants.shuffle)

        format.html { redirect_to competition_competitors_path(@competition), notice:  message }
        format.json { render json: @competition, status: :created, location: competition_competitors_path(@event) }
      else
        load_event_category
        format.html { render action: "new" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /competitions/1
  # PUT /competitions/1.json
  def update
    @competition = Competition.find(params[:id])

    respond_to do |format|
      if @competition.update_attributes(params[:competition])
        format.html { redirect_to @competition, notice: 'Competition was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1
  # DELETE /competitions/1.json
  def destroy
    @competition = Competition.find(params[:id])
    event = @competition.event
    @competition.destroy

    respond_to do |format|
      format.html { redirect_to event_competitions_path(event) }
      format.json { head :no_content }
    end
  end

  def freestyle_scores
  end

  def export_scores
    if @competition.event.event_class == 'Two Attempt Distance'
      csv_string = CSV.generate do |csv|
        csv << ['registrant_external_id', 'distance']
        @competition.competitors.each do |comp|
          da = comp.max_successful_distance
          if da != 0
            csv << [comp.external_id,
              da]
          end
        end
      end
    else
      csv_string = CSV.generate do |csv|
        csv << ['judge_id', 'judge_type_id', 'registrant_external_id', 'val1', 'val2', 'val3', 'val4']
        @competition.scores.each do |score|
          csv << [score.judge.external_id,
            score.judge.judge_type.name,
            score.competitor.export_id, # use a single value even in groups
            score.val_1,
            score.val_2,
            score.val_3,
            score.val_4]
        end
      end
    end
    filename = @competition.name.downcase.gsub(/[^0-9a-z]/, "_") + ".csv"
    send_data(csv_string,
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => filename)
  end

  def lock
    if request.post?
      @competition.locked = true
    elsif request.delete?
      @competition.locked = false
    end

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: 'Updated lock status' }
      else
        format.html { redirect_to @competition, notice: 'Unable to update lock status' }
      end
    end
  end

  # GET /competitions/#/get_import_time_results
  def get_import_time_results
  end

  # GET /competitions/#/confirm_import_time_results
  def confirm_import_time_results
    upload = Upload.new
    @data = upload.extract_csv(params[:file])
  end

  # POST /competitions/#/import_time_results
  def import_time_results
    upload = Upload.new
    @data = upload.extract_csv(params[:file])
    n = 0
    @data.each do |row|
      tr = TimeResult.new
      comp = @competition.find_competitor_with_bib_number(row[0])
      if comp.nil?
        comp = @competition.competitors.build
        member = comp.members.build
        member.registrant = Registrant.find_by_bib_number(row[0])
        if !comp.save
          comp.errors.each do |err|
            puts "error creating competitor because: #{err}"
          end
        end
      end
      tr.minutes = row[1]
      tr.seconds = row[2]
      tr.thousands = row[3]
      tr.disqualified = row[4] == "DQ"
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
      format.html { redirect_to @competition, notice: "Added #{n} rows to #{@competition}" }
    end
  end
end

