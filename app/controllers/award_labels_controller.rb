class AwardLabelsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_new_award_label, :only => [:create]
  load_and_authorize_resource

  before_filter :load_user, :only => [:index, :create, :create_labels, :expert_labels, :normal_labels, :destroy_all, :create_labels_by_registrant]

  def load_new_award_label
    @award_label = AwardLabel.new(award_label_params)
  end

  def load_user
    @user = User.find(params[:user_id])
  end

  # GET /users/#/award_labels
  # GET /users/#/award_labels.json
  def index
    @award_labels = @user.award_labels.includes(:registrant).all
    @award_label = AwardLabel.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @award_labels }
    end
  end

  # GET /award_labels/1/edit
  def edit
    @user = @award_label.user
  end

  # POST /users/#/award_labels
  # POST /users/#/award_labels.json
  def create
    @award_label.user = @user

    respond_to do |format|
      if @award_label.save
        format.html { redirect_to user_award_labels_path(@user), notice: 'Award label was successfully created.' }
      else
        @award_labels = @user.award_labels
        format.html { render action: "index" }
      end
    end
  end

  # PUT /award_labels/1
  # PUT /award_labels/1.json
  def update

    respond_to do |format|
      if @award_label.update_attributes(award_label_params)
        format.html { redirect_to user_award_labels_path(@award_label.user), notice: 'Award label was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @award_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /award_labels/1
  # DELETE /award_labels/1.json
  def destroy
    @user = @award_label.user
    @award_label.destroy

    respond_to do |format|
      format.html { redirect_to user_award_labels_path(@user) }
      format.json { head :no_content }
    end
  end

  def create_labels
    if params[:minimum_place].nil? or params[:minimum_place].empty?
      min_place = 1
    else
      min_place = params[:minimum_place].to_i
    end

    if params[:maximum_place].nil? or params[:maximum_place].empty?
      max_place = 5
    else
      max_place = params[:maximum_place].to_i
    end

    if params[:age_groups].nil? or params[:age_groups].empty?
      age_groups = false
    else
      age_groups = params[:age_groups]
    end

    if params[:experts].nil? or params[:experts].empty?
      experts = false
    else
      experts = params[:experts]
    end
    puts "min: #{min_place}, max: #{max_place} age: #{age_groups} exp: #{experts}"

    n = 0
    unless params[:registrant_id].nil? or params[:registrant_id].empty?
      @registrant = Registrant.find(params[:registrant_id])

      @registrant.competitors.each do |competitor|
        n += create_labels_for_competitor(competitor, @registrant, @user, age_groups, experts, min_place, max_place)
      end
    end

    unless params[:registrant_group_id].nil? or params[:registrant_group_id].empty?
      @registrant_group = RegistrantGroup.find(params[:registrant_group_id])

      @registrant_group.registrant_group_members.includes(:registrant).each do |member|
        member.registrant.competitors.includes(:competition).each do |competitor|
          n += create_labels_for_competitor(competitor, member.registrant, @user, age_groups, experts, min_place, max_place)
        end
      end
    end
    unless params[:competition_id].nil? or params[:competition_id].empty?
      @competition = Competition.find(params[:competition_id])
      @competition.competitors.each do |competitor|
        competitor.members.each do |member|
          n += create_labels_for_competitor(competitor, member.registrant, @user, age_groups, experts, min_place, max_place)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to user_award_labels_path(@user), notice: "Created #{n} labels." }
    end
  end

  def create_labels_for_competitor(competitor, registrant, user, age_groups, experts, min_place, max_place)
    n = 0
    competition = competitor.competition
    if age_groups
      if competition.has_non_expert_results and competitor.place.to_i <= max_place
        if create_label(competitor, registrant, false, min_place, max_place, user)
          n += 1
        end
      end
    end
    if experts
      if competition.has_experts
        if create_label(competitor, registrant, true, min_place, max_place, user)
          n += 1
        end
      end
    end
    n
  end

  def create_label(competitor, registrant, experts, min_place, max_place, my_user)
    if experts
      place = competitor.overall_place
    else
      place = competitor.place
    end
    return false if place == "DQ"
    return false if place.to_i == 0
    return false if place.to_i < min_place
    return false if place.to_i > max_place

    aw_label = AwardLabel.new
    aw_label.user = my_user
    aw_label.populate_from_competitor(competitor, registrant, experts)

    return aw_label.save
  end

  def destroy_all
    @user.award_labels.destroy_all
    redirect_to user_award_labels_path(@user)
  end

  def normal_labels
    separate_registrants = false
    unless params[:separate_registrants].nil?
      separate_registrants = true
    end
    previous_bib_number = 0

    skip_positions = 0
    unless params[:skip_positions].nil? or params[:skip_positions].empty?
      skip_positions = params[:skip_positions].to_i
    end

    names = []
    skip_positions.times do
      names << ""
    end
    @user.award_labels.order(:bib_number).each do |label|
      if separate_registrants and (previous_bib_number != 0 and label.bib_number != previous_bib_number)
        # add 3 blanks
        names << ""
        names << ""
        names << ""
      end
      previous_bib_number = label.bib_number

      lines = ""
      line = label.line_1
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_2
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_3
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_4
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_5
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_6
      lines += "<b>" + line + "</b>" unless line.nil? or line.empty?
      names << lines
    end

    Prawn::Labels.types = {
      "Avery5160padded" => {
      "paper_size" => "LETTER",
      "top_margin" => 36,
      "bottom_margin" => 36,
      "left_margin" => 15.822,
      "right_margin" => 15.822,
      "columns" => 3,
      "rows" => 10,
      "column_gutter" => 15,
      "row_gutter" => 2.5 # added padding
    }
    }

    labels = Prawn::Labels.render(names, :type => "Avery5160padded", :shrink_to_fit => true) do |pdf, name|
      pdf.text name, :align =>:center, :valign => :center, :inline_format => true
    end

    send_data labels, :filename => "normal-labels-#{Date.today}.pdf"
  end

  def expert_labels

    names = []
    @user.award_labels.each do |label|
      lines = ""
      line = label.line_1
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_2
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_3
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_4
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_5
      lines += line + "\n" unless line.nil? or line.empty?
      line = label.line_6
      lines += "<b>" + line + "</b>" unless line.nil? or line.empty?
      names << lines
    end
    Prawn::Labels.types = {
      "Avery5293" => {
        "paper_size" => "LETTER",
        "top_margin" => 38.23, # 0.531"
        "bottom_margin" => 38.23, # 0.531"
        "left_margin" =>  38.23, # 0.406 "
        "right_margin" =>  29.23, # 0.406"
        "columns" =>  4,
        "rows" =>  6,
        "column_gutter" =>  20.152, # 0.391 "
        "row_gutter" =>  6.152 # 0.391"

        #"top_margin" => 13.49, # 0.531"
        #"bottom_margin" => 13.49, # 0.531"
        #"left_margin" =>  10.31, # 0.406 "
        #"right_margin" =>  10.31, # 0.406"
        #"columns" =>  4,
        #"rows" =>  6,
        #"column_gutter" =>  9.93, # 0.391 "
        #"row_gutter" =>  9.93 # 0.391"
    }
    }

    labels = Prawn::Labels.render(names, :type => "Avery5293", :shrink_to_fit => true) do |pdf, name|
      pdf.text name, :align => :center, :inline_format => true, :valign => :center
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  private
  def award_label_params
    params.require(:award_label).permit(:age_group, :bib_number, :competition_name, :details, :competitor_name, :category,
                                        :place, :registrant_id, :team_name, :user_id)
  end
end
