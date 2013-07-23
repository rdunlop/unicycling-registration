require 'csv'
class CompetitorsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_competition, :only => [:index, :new, :create, :upload, :add_all, :destroy_all, :create_from_sign_ups]

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  # GET /competitions/:competition_id/1/new
  def new
    @registrants = @competition.event.signed_up_registrants
    @competitor = @competition.competitors.new
  end

  def create_from_sign_ups
    @registrants = @competition.event.signed_up_registrants

    new_competitors = @registrants.shuffle
    n = add_registrants(new_competitors)

    respond_to do |format|
      if n > 0
        format.html { redirect_to new_competition_competitor_path(@competition), notice: "#{n} Competition registrants successfully created." }
      else
        format.html { render "new", alert: 'Error adding Registrants (0 added)' }
      end
    end
  end

  # GET /competitions/1/competitors
  def index
    @competitors = @competition.competitors
  end

  # GET /competitors/1/edit
  def edit
  end

  def add_all
    @competitor = @competition.competitors.new # so that the form renders ok

    n = add_registrants(Registrant.all)

    respond_to do |format|
      if n > 0
        format.html { redirect_to new_competition_competitor_path(@competition), notice: "#{n} Competition registrants successfully created." }
      else
        format.html { render "new", alert: 'Error adding Registrants (0 added)' }
      end
    end
  end

  def add_registrants(registrants = [])
    n = 0
    current_registrant_external_ids = @competition.registrants.map {|r| r.external_id}
    registrants.each do |reg|
      next if reg.nil?
        if !reg.competitor
            next
        end
        if current_registrant_external_ids.include? reg.external_id
            #puts "found existing"
        else
            comp = @competition.competitors.new
            # set the position to be 1 more than current positions
            comp.position = @competition.competitors.count + 1
            if comp.save
                #puts "successfully saved competitor"
                member = comp.members.new
                member.registrant = reg
                if member.save
                    n = n+1
                else
                    member.errors.each do |err|
                        puts "merr: #{err}"
                    end
                end
            else
                comp.errors.each do |err|
                    puts "error #{err}"
                end
            end
        end
    end
    n
  end

  # POST /competitors
  # POST /competitors.json
  def create
    @competitor.competition = @competition

    respond_to do |format|
      if @competitor.save
        format.html { redirect_to competition_competitors_path(@competition), notice: 'Competition registrant was successfully created.' }
        format.json { render json: @competitor, status: :created, location: @competitor }
      else
        format.html { render "new", alert: 'Error adding Registrant' }
        format.json { render json: @competitor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /competitors/1
  # PUT /competitors/1.json
  def update
    respond_to do |format|
      if @competitor.update_attributes(params[:competitor])
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
      row = CSV.parse_line (line)

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
        else
            # Group freestyle-format
            # format: order,group_id,group_name
            # sample rows:
            #2,3019,undesided
            #3,3020,Hino
            #4,3017,israel unicycle org
            comp = @competition.competitors.create(:position => row[0].to_i)
            comp.custom_external_id = row[1]
            comp.custom_name = row[2]
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
end
