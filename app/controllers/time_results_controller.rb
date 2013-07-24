class TimeResultsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :competition, :except => [:edit, :destroy, :update]
  load_and_authorize_resource :time_result, :except => [:edit, :destroy, :update]
  load_and_authorize_resource :time_result, :only => [:edit, :destroy, :update]

  # XXX look into https://github.com/railscasts/396-importing-csv-and-excel/blob/master/store-with-validations/app/models/product_import.rb ??
  
  # GET event/1/time_results
  # GET event/1/time_results.json
  def index
    @time_results = @competition.time_results # XXX
    @time_result = TimeResult.new # @event.time_results.build

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @time_results }
    end

  end

  def final_candidates
    @male_time_results = @competition.time_results.select{ |time_result| time_result.is_top?("Male") }
    @female_time_results = @competition.time_results.select{ |time_result| time_result.is_top?("Female") }
    respond_to do |format|
      format.html # final_candidates.html.erb
    end
  end

  def set_places
    @calc = RaceCalculator.new(@competition)
    @calc.update_all_places
    #@event.competitions.each do |competition|
      #@calc = RaceCalculator.new(competition)
      #@calc.update_all_places
    #end
    redirect_to competition_time_results_path(@competition), :notice => "All Places updated"
  end

  # GET /time_results/1/edit
  def edit
    @time_result = TimeResult.find(params[:id])
  end

  # POST event/1/time_results
  # POST event/1/time_results.json
  def create

    respond_to do |format|
      if @time_result.save
        format.html { redirect_to(event_time_results_path(@time_result.event), :notice => 'Time result was successfully created.') }
        format.json { render :json => @time_result, :status => :created, :location => @time_result.event }
      else
        @time_results = @event.time_results
        format.html { render :action => "index" }
        format.json { render :json => @time_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT time_results/1
  # PUT time_results/1.json
  def update
    respond_to do |format|
      if @time_result.update_attributes(params[:time_result])
        format.html { redirect_to(competition_time_results_path(@time_result.competition), :notice => 'Time result was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @time_result.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE time_results/1
  # DELETE time_results/1.json
  def destroy
    event = @time_result.event
    @time_result.destroy

    respond_to do |format|
      format.html { redirect_to event_time_results_path(event) }
      format.json { head :ok }
    end
  end
end
