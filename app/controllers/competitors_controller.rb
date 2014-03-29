require 'csv'
class CompetitorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_competition, :only => [:index, :new, :create, :add, :upload, :add_all, :destroy_all, :create_from_sign_ups]
  before_filter :load_new_competitor, :only => [:create]
  load_and_authorize_resource :through => :competition, :except => [:edit, :update, :destroy]
  load_and_authorize_resource :only => [:edit, :update, :destroy]

  private
  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_new_competitor
    @competitor = @competition.competitors.new(competitor_params)
  end

  public
  # GET /competitions/:competition_id/1/new
  def new
    @registrants = @competition.signed_up_registrants
    @competitor = @competition.competitors.new
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
          msg = @competition.create_competitor_from_registrants(regs, params[:group_name])
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

    respond_to do |format|
      if @competitor.save
        format.html { redirect_to competition_competitors_path(@competition), notice: 'Competition registrant was successfully created.' }
        format.json { render json: @competitor, status: :created, location: @competitor }
      else
        @registrants = @competition.signed_up_registrants
        format.html { render "new", alert: 'Error adding Registrant' }
        format.json { render json: @competitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /competitors/1
  # PUT /competitors/1.json
  def update
    respond_to do |format|
      if @competitor.update_attributes(competitor_params)
        format.html { redirect_to competition_competitors_path(@competitor.competition), notice: 'Competition registrant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @competitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitors/1
  # DELETE /competitors/1.json
  def destroy
    @ev_cat = @competitor.competition
    @competitor.destroy

    respond_to do |format|
      format.html { redirect_to competition_competitors_path(@ev_cat) }
      format.json { head :no_content }
    end
  end

  # DELETE /events/10/competitors/destroy_all
  def destroy_all
    @competition.competitors.destroy_all

    respond_to do |format|
      format.html { redirect_to new_competition_competitor_path(@competition) }
      format.json { head :no_content }
    end
  end

  def upload
    n=0
    if params[:import][:file].respond_to?(:tempfile)
        upload_file = params[:import][:file].tempfile
    else
        upload_file = params[:import][:file]
    end
    File.open(upload_file, 'r:ISO-8859-1') do |f|
     f.each do |line|
      row = CSV.parse_line(line)

      if row.count == 1
        # High/Long forme
        #format: registrant_id
        # sample rows:
        # 328
        # 329
        reg = get_registrant(row[0].to_i)
        if (!reg.nil?)
            position = @competition.competitors.count + 1
            comp = @competition.competitors.create(:position => position)
            comp.members.build(:registrant_id => reg.id)
        else
            return
        end
      elsif row.count == 2
        # Individual freestyle-format
        #format: order,registrant_id
        # sample rows:
        #1,328
        #2,329
        reg = get_registrant(row[1].to_i)
        if (!reg.nil?)
           comp = @competition.competitors.create(:position => row[0].to_i)
           comp.members.build(:registrant_id => reg.id)
        else
           return
        end
      elsif row.count == 3
        if (numeric?(row[2]))
            # Pairs freestyle-format
            #format: order,registrant_id,registrant_id
            # sample rows:
            #1,328,330
            #2,329,331
            reg  = get_registrant(row[1].to_i)
            reg2 = get_registrant(row[2].to_i)
            if (!reg.nil? && !reg2.nil?)
                comp = @competition.competitors.create(:position => row[0].to_i)
                comp.members.build(:registrant_id => reg.id)
                comp.members.build(:registrant_id => reg2.id)
            else
                return
            end
        end
      end

      if comp.save
        n=n+1
      else
         flash[:alert]="Unable to import line #{row}. #{comp.errors.full_messages}"
         redirect_to competition_path(@competition)
         return
      end
     end
    end
    flash[:notice]="CSV Import Successful,  #{n} new records added to data base"
    redirect_to competition_path(@competition)
  end

  private
  def get_registrant(id)
    reg2 = Registrant.find_by_bib_number(id)
    if (reg2.nil?)
        flash[:alert]="Unable to import line with id #{id}, Unable to find matching registrant in database"
        redirect_to competition_path(@competition)
    end
    reg2
  end

  def competitor_params
    params.require(:competitor).permit(:position, {:registrant_ids => []}, :custom_external_id, :custom_name)
  end
end
