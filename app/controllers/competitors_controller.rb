require 'csv'
class CompetitorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_competition, :only => [:index, :new, :create, :add, :add_all, :destroy_all, :create_from_sign_ups]
  before_filter :load_new_competitor, :only => [:create]
  load_and_authorize_resource :through => :competition, :except => [:edit, :update, :destroy]
  load_and_authorize_resource :only => [:edit, :update, :destroy]

  respond_to :html

  private
  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_competitor
    @competitor = @competition.competitors.new(competitor_params)
  end

  public
  # GET /competitions/:competition_id/1/competitors/new
  def new
    @filtered_registrants = @competition.signed_up_registrants
    @competitor = @competition.competitors.new
    @competitor.members.build #add an initial member
  end

  # GET /competitions/1/competitors
  def index
    @registrants = @competition.signed_up_registrants
    @competitors = @competition.competitors
  end

  def add
    regs = params[:registrants].map{|reg_id| Registrant.find(reg_id) }

    respond_to do |format|
      begin
        if params[:commit] == Competitor.group_selection_text
          @competition.create_competitor_from_registrants(regs, params[:group_name])
          msg = "Created Group Competitor"
        elsif params[:commit] == Competitor.not_qualified_text
          msg = @competition.create_competitors_from_registrants(regs, "not_qualified")
        else
          msg = @competition.create_competitors_from_registrants(regs)
        end
        format.html { redirect_to competition_competitors_path(@competition), notice: msg }
      rescue Exception => ex
        index
        format.html { render "index", alert: "Error adding Registrants (0 added) #{ex}" }
      end
    end
  end

  # GET /competitors/1/edit
  def edit
  end

  def add_all
    @competitor = @competition.competitors.new # so that the form renders ok

    respond_to do |format|
      begin
        msg = @competition.create_competitors_from_registrants(Registrant.where(:competitor => true))
        format.html { redirect_to new_competition_competitor_path(@competition), notice: msg }
      rescue Exception => ex
        new
        format.html { render "new", alert: "Error adding Registrants. #{ex}" }
      end
    end
  end

  # POST /competitors
  # POST /competitors.json
  def create
    if @competitor.save
      flash[:notice] = 'Competition registrant was successfully created.'
    else
      @registrants = @competition.signed_up_registrants
      flash[:alert] = 'Error adding Registrant'
    end

    respond_with(@competitor, location: competition_competitors_path(@competition))
  end

  # PUT /competitors/1
  # PUT /competitors/1.json
  def update
    if @competitor.update_attributes(competitor_params)
      flash[:notice] = 'Competition registrant was successfully updated.'
    end
    respond_with(@competitor, location: competition_competitors_path(@competitor.competition), action: "edit")
  end

  # DELETE /competitors/1
  # DELETE /competitors/1.json
  def destroy
    @ev_cat = @competitor.competition
    @competitor.destroy

    respond_with(@competition, location: competition_competitors_path(@ev_cat))
  end

  # DELETE /events/10/competitors/destroy_all
  def destroy_all
    @competition.competitors.destroy_all

    respond_with(@competition, location: new_competition_competitor_path(@competition))
  end

  private

  def competitor_params
    params.require(:competitor).permit(:status, :position, :custom_name, {:members_attributes => [:registrant_id, :id, :_destroy] } )
  end
end
