require 'csv'
class CompetitorsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :competition, except: [:edit, :update, :destroy]
  before_filter :load_new_competitor, :only => [:create]
  load_and_authorize_resource :through => :competition, :except => [:edit, :update, :destroy]
  load_and_authorize_resource :only => [:edit, :update, :destroy]

  before_action :set_parent_breadcrumbs, only: [:index, :enter_sign_in, :new, :edit, :display_candidates]

  respond_to :html

  # GET /competitions/:competition_id/1/competitors/new
  def new
    add_breadcrumb "Add Competitor"
    @filtered_registrants = @competition.signed_up_registrants
    @competitor = @competition.competitors.new
    @competitor.members.build #add an initial member
  end

  # GET /competitions/1/competitors
  def index
    add_breadcrumb "Manage Competitors"
    @registrants = @competition.signed_up_registrants
    @competitors = @competition.competitors
  end

  # show the competitors, their overall places, and their times
  def display_candidates
    add_breadcrumb "Display Competition Candidates"
    @competitors = @competition.signed_up_competitors
  end

  # process a form submission which includes HEAT&Lane for each candidate, creating the competitor as well as the lane assignment
  def create_from_candidates
    heat = params[:heat].to_i
    competitors = params[:competitors]
    begin
      LaneAssignment.transaction do
        competitors.each do |_, competitor|
          reg = Registrant.find_by(bib_number: competitor[:bib_number])
          lane_assignment = LaneAssignment.new(registrant_id: reg.id, lane: competitor[:lane].to_i, heat: heat, competition: @competition)
          lane_assignment.save!
        end
      end
      flash[:notice] = "Created Lane Assignments & Competitors"
    rescue Exception => ex
      flash[:alert] = "Error creating lane assignments/competitors #{ex}"
    end
    redirect_to competition_competitors_path(@competition)
  end

  def enter_sign_in
    add_breadcrumb "Enter Sign-In"
    @competitors = @competition.competitors.reorder(:lowest_member_bib_number)
  end

  def update_competitors
    respond_to do |format|
      if @competition.update_attributes(update_competitors_params)
        flash[:notice] = 'Competitors successfully updated.'
        format.html { redirect_to :back }
      else
        enter_sign_in
        format.html { render "enter_sign_in" }
      end
    end
  end

  def add

    respond_to do |format|
      begin
        raise "No Registrants selected" if params[:registrants].nil?
        regs = params[:registrants].map{|reg_id| Registrant.find(reg_id) }
        if params[:commit] == Competitor.group_selection_text
          @competition.create_competitor_from_registrants(regs, params[:group_name])
          msg = "Created Group Competitor"
        elsif params[:commit] == Competitor.not_qualified_text
          @competition.create_competitors_from_registrants(regs, "not_qualified")
          msg = "Non-Qualified Competitors created"
        else
          @competition.create_competitors_from_registrants(regs)
          msg = "Created #{regs.count} Competitors"
        end
        format.html { redirect_to competition_competitors_path(@competition), notice: msg }
      rescue Exception => ex
        index
        flash.now[:alert] = "Error adding Registrants (0 added) #{ex}"
        format.html { render "index"  }
      end
    end
  end

  # GET /competitors/1/edit
  def edit
    add_breadcrumb "Edit Competitor"
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
      flash.now[:alert] = 'Error adding Registrant'
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
    params.require(:competitor).permit(:status, :position, :custom_name, :heat, :geared, :riding_wheel_size, :riding_crank_size, :notes, {:members_attributes => [:registrant_id, :id, :_destroy] } )
  end

  def update_competitors_params
    params.require(:competition).permit(:competitors_attributes => [:id, :status, :heat, :geared, :riding_wheel_size, :riding_crank_size, :notes])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_competitor
    @competitor = @competition.competitors.new(competitor_params)
  end

  def set_parent_breadcrumbs
    @competition ||= @competitor.competition
    add_breadcrumb "#{@competition}", competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition) if @competitor
  end
end
