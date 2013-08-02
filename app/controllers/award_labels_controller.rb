class AwardLabelsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_user, :only => [:index, :create, :create_labels, :expert_labels, :normal_labels, :destroy_all, :create_labels_by_registrant]

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
    @award_label = AwardLabel.find(params[:id])
    @user = @award_label.user
  end

  # POST /users/#/award_labels
  # POST /users/#/award_labels.json
  def create
    @award_label = AwardLabel.new(params[:award_label])
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
    @award_label = AwardLabel.find(params[:id])

    respond_to do |format|
      if @award_label.update_attributes(params[:award_label])
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
    @award_label = AwardLabel.find(params[:id])
    @user = @award_label.user
    @award_label.destroy

    respond_to do |format|
      format.html { redirect_to user_award_labels_path(@user) }
      format.json { head :no_content }
    end
  end

  def create_labels_by_registrant
    unless params[:registrant_id].nil? or params[:registrant_id].empty?
      @registrant = Registrant.find(params[:registrant_id])

      n = 0
      @registrant.competitors.each do |competitor|
        n += create_labels_for_competitor(competitor, @registrant, @user)
      end
    end

    unless params[:registrant_group_id].nil? or params[:registrant_group_id].empty?
      @registrant_group = RegistrantGroup.find(params[:registrant_group_id])

      n = 0
      @registrant_group.registrant_group_members.includes(:registrant).each do |member|
        member.registrant.competitors.includes(:competition).each do |competitor|
          n += create_labels_for_competitor(competitor, member.registrant, @user)
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to user_award_labels_path(@user), notice: "Created #{n} labels." }
    end
  end

  def create_labels_for_competitor(competitor, registrant, user)
    n = 0
    competition = competitor.competition
    if competition.has_age_groups and competitor.place.to_i <= 5
      if create_label(competitor, registrant, false, 1, 5, user)
        n += 1
      end
    end
    if competition.has_experts
      if create_label(competitor, registrant, true, 4, 5, user)
        n += 1
      end
    end
    n
  end

  def create_label(competitor, registrant, experts, min_place, max_place, my_user)
    competition = competitor.competition
    if experts
      place = competitor.overall_place
    else
      place = competitor.place
    end
    return false if place == "DQ"
    return false if place.to_i == 0
    return false if place.to_i < min_place
    return false if place.to_i > max_place

    # do this later, so that we can exit more cheaply
    if experts
      age_group = "Expert " + competitor.gender # because the only age gorup is the normal age group
    else
      age_group = competitor.age_group_description
    end

    competition_name = competition.event.name
    if competition.event.event_class == "Freestyle" ### XXX Somewhere else?
      age_group = competition.name # the "Category"
    elsif competition.event.event_class == "Distance"
      competition_name = competition.name # the "Category"
    end

    aw_label = AwardLabel.new
    aw_label.competition_name = competition_name
    aw_label.age_group = age_group
    aw_label.bib_number = registrant.bib_number
    aw_label.details = competitor.result
    aw_label.first_name = registrant.first_name
    aw_label.last_name = registrant.last_name
    aw_label.gender = competitor.gender
    if competitor.members.count > 1
      aw_label.gender = nil
    end
    if competitor.members.count == 2
      reg1 = competitor.members.first.registrant
      reg2 = competitor.members.last.registrant
      if reg1 == registrant
        reg = reg2
      else
        reg = reg1
      end
      aw_label.partner_first_name = reg.first_name
      aw_label.partner_last_name = reg.last_name
    else
      aw_label.partner_first_name = nil
      aw_label.partner_last_name = nil
    end
    aw_label.place = place
    aw_label.registrant_id = registrant.id
    aw_label.team_name = competitor.team_name
    aw_label.user = my_user
    return aw_label.save
  end
  # creates the award labels, as per the specified option(s)
  def create_labels
    @competition = Competition.find(params[:competition_id])

    if params[:maximum_place].nil? or params[:maximum_place].empty?
      max_place = 5 
    else
      max_place = params[:maximum_place].to_i
    end

    experts = !params[:experts].nil?
    n = 0
    @competition.competitors.each do |competitor|
      competitor.members.each do |member|
        if create_label(competitor, member.registrant, experts, 1, max_place, @user)
          n += 1
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to user_award_labels_path(@user), notice: "Created #{n} labels." }
    end
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

    names = []
    @user.award_labels.order(:bib_number).each do |label|
      if separate_registrants and (previous_bib_number != 0 and label.bib_number != previous_bib_number)
        # add 3 blanks
        names << ""
        names << ""
        names << ""
      end
      previous_bib_number = label.bib_number

      lines = ""
      line = line_one(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_two(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_three(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_four(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_five(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_six(label)
      lines += "<b>" + line + "</b>" unless line.nil? or line.empty?
      names << lines
    end


    labels = Prawn::Labels.render(names, :type => "Avery5160") do |pdf, name|
      pdf.text name, :align =>:center, :valign => :center, :size => 10, :inline_format => true, :shrink_to_fit => true
    end

    send_data labels, :filename => "normal-labels-#{Date.today}.pdf"
  end

  def expert_labels

    names = []
    @user.award_labels.each do |label|
      lines = ""
      line = line_one(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_two(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_three(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_four(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_five(label)
      lines += line + "\n" unless line.nil? or line.empty?
      line = line_six(label)
      lines += "<b>" + line + "</b>" unless line.nil? or line.empty?
#      lines = "<div><div style=\"display: inline-block; vertical-align: middle; height: 100%; width: 0;\"></div><div style=\"vertical-align: middle; display: inline-block;\">" + lines + "</div>"
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

    labels = Prawn::Labels.render(names, :type => "Avery5293") do |pdf, name|
      pdf.text name, :align => :center, :size => 10, :inline_format => true, :shrink_to_fit => true, :valign => :center
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  private
  def line_one(award)
    res = award.first_name + " " + award.last_name
    unless award.partner_first_name.nil? or award.partner_first_name.blank?
      res += " & " + award.partner_first_name + " " + award.partner_last_name
    end
    res
  end

  def line_two(award)
    award.competition_name
  end

  def line_three(award)
      award.team_name
  end

  def line_four(award)
    res = ""
    unless award.age_group.nil? or award.age_group.empty?
      res += award.age_group
    else
      # No Age Group?
      unless award.gender.nil? or award.gender.empty?
        res += award.gender
      end
    end
    res
  end

  def line_five(award)
    award.details
  end

  def line_six(award)
    case award.place
    when 1
      "1st Place"
    when 2
        "2nd Place"
    when 3
        "3rd Place"
    when 4
        "4th Place"
    when 5
        "5th Place"
    when 6
        "6th Place"
    end
  end
end
