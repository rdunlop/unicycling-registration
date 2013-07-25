class AwardLabelsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_user, :only => [:index, :create, :create_labels, :expert_labels, :normal_labels, :destroy_all]

  def load_user
    @user = User.find(params[:user_id])
  end

  # GET /users/#/award_labels
  # GET /users/#/award_labels.json
  def index
    @award_labels = AwardLabel.all
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
      names << lines
    end
    Prawn::Labels.types = {
      "Avery5293" => {
        "paper_size" => "A4",
        "top_margin" => 13.49, # 0.531"
        "bottom_margin" => 13.49, # 0.531"
        "left_margin" =>  10.31, # 0.406 "
        "right_margin" =>  10.31, # 0.406"
        "columns" =>  4,
        "rows" =>  6,
        "column_gutter" =>  9.93, # 0.391 "
        "row_gutter" =>  9.93 # 0.391"
    }
    }

    labels = Prawn::Labels.render(names, :type => "Avery5293") do |pdf, name|
      pdf.text name, :align => :center, :size => 10, :inline_format => true, :shrink_to_fit => true
    end

    send_data labels, :filename => "bag-labels-#{Date.today}.pdf", :type => "application/pdf"
  end

  private
  def line_one(award)
    res = award.first_name + " " + award.last_name
    unless award.partner_first_name.nil?
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
    end
    unless award.gender.nil? or award.gender.empty?
      if res != ""
        res += " "
      end
      res += award.gender
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
