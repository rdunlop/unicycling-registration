class CompetitorsController < ApplicationController
  layout "competition_management"
  include SortableObject

  before_action :authenticate_user!
  before_action :load_competition, except: [:edit, :update, :destroy, :withdraw, :update_row_order]
  before_action :load_competitor, only:    [:edit, :update, :destroy, :withdraw, :update_row_order]

  before_action :set_parent_breadcrumbs, only: [:index, :new, :edit, :display_candidates]
  before_action :authorize_sort, only: :update_row_order

  respond_to :html

  # GET /competitions/:competition_id/1/competitors/new
  def new
    add_breadcrumb "Add Competitor"
    @filtered_registrants = @competition.signed_up_registrants
    @competitor = @competition.competitors.new
    authorize @competitor
    @competitor.members.build # add an initial member
  end

  # GET /competitions/1/competitors
  def index
    authorize @competition.competitors.new
    add_breadcrumb "Manage Competitors"
    @registrants = @competition.signed_up_registrants
    @competitors = @competition.competitors.includes(members: [:registrant])
  end

  # show the competitors, their overall places, and their times
  def display_candidates
    authorize @competition.competitors.new
    add_breadcrumb "Display Competition Candidates"
    @competitors = @competition.signed_up_competitors
  end

  # process a form submission which includes HEAT&Lane for each candidate, creating the competitor as well as the lane assignment
  def create_from_candidates
    authorize @competition.competitors.new

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

  def add
    authorize @competition.competitors.new

    respond_to do |format|
      begin
        raise "No Registrants selected" if params[:registrants].nil?
        regs = Registrant.find(params[:registrants])
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
    authorize @competitor

    add_breadcrumb "Edit Competitor"
  end

  def add_all
    authorize @competition.competitors.new

    @competitor = @competition.competitors.new # so that the form renders ok
    respond_to do |format|
      begin
        msg = @competition.create_competitors_from_registrants(Registrant.competitor)
        format.html { redirect_to new_competition_competitor_path(@competition), notice: msg }
      rescue Exception => ex
        new
        flash.now[:alert] = "Error adding Registrants. #{ex}"
        format.html { render "new" }
      end
    end
  end

  # POST /competitors
  # POST /competitors.json
  def create
    @competitor = @competition.competitors.new(competitor_params)
    authorize @competitor
    if @competitor.save
      flash[:notice] = 'Competition registrant was successfully created.'
      respond_to do |format|
        format.html { redirect_to competition_competitors_path(@competition) }
        format.js
      end
    else
      @registrants = @competition.signed_up_registrants
      flash.now[:alert] = 'Error adding Registrant'
      respond_to do |format|
        format.html { render :new }
        format.js
      end
    end
  end

  # PUT /competitors/1
  # PUT /competitors/1.json
  def update
    authorize @competitor

    if @competitor.update_attributes(competitor_params)
      flash[:notice] = 'Competition registrant was successfully updated.'
      redirect_to competition_competitors_path(@competitor.competition)
    else
      @competition = @competitor.competition
      render :edit
    end
  end

  # DELETE /competitors/1
  # DELETE /competitors/1.json
  def destroy
    authorize @competitor
    @ev_cat = @competitor.competition
    @competitor.destroy
    respond_to do |format|
      format.js {}
      format.html { redirect_to competition_competitors_path(@ev_cat) }
    end
  end

  # PUT /competitors/1/withdraw
  def withdraw
    authorize @competitor
    @competitor.update_attributes(status: "withdrawn")
    flash[:notice] = "Competitor #{@competitor} withdrawn"
    redirect_to competition_competitors_path(@competitor.competition)
  end

  # DELETE /events/10/competitors/destroy_all
  def destroy_all
    authorize @competition.competitors.new

    @competition.competitors.destroy_all

    respond_with(@competition, location: new_competition_competitor_path(@competition))
  end

  private

  def authorize_sort
    authorize @competitor, :sort?
  end

  def sortable_object
    Competitor.find(params[:id])
  end

  def competitor_params
    params.require(:competitor).permit(:status, :custom_name, members_attributes: [:registrant_id, :id, :_destroy])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_competitor_through_competition
    @competitor = @competition.competitors.find(params[:id])
  end

  def load_competitor
    @competitor = Competitor.find(params[:id])
  end

  def set_parent_breadcrumbs
    @competition ||= @competitor.competition
    add_breadcrumb "#{@competition}", competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition) if @competitor
  end
end
