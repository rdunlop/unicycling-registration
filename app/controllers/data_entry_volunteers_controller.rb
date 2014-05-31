class DataEntryVolunteersController < ApplicationController
  load_and_authorize_resource :competition
  before_action :load_new_data_entry_volunteer, only: :index

  respond_to :html


  def index
    add_to_competition_breadcrumb(@competition)
    add_breadcrumb "Manage Data Entry Volunteers", competition_data_entry_volunteers_path(@competition)

    @all_data_entry_volunteers = User.with_role(:data_entry_volunteer).order(:email)
    @race_officials = User.with_role(:race_official).order(:email)

    @events = Event.all
  end

  # POST /competitions/#/judges
  # POST /competitions/#/judges.json
  def create
    @data_entry_volunteer = DataEntryVolunteer.new(params[:data_entry_volunteer])
    if @data_entry_volunteer.save
      flash[:notice] = 'Data Entry Volunteer was successfully created.'
    else
      index
    end
    respond_with(@judge, location: competition_data_entry_volunteers_path(@competition), action: "index")
  end

=begin
  # this is used to update standard_execution_scores
  # PUT /judge/1
  def update

    respond_to do |format|
      if @judge.update_attributes(judge_params)
        format.html { redirect_to judge_standard_scores_path(@judge), notice: 'Judge Scores successfully created.' }
      else
        new # call new function (above), to load the correct variables
        format.html { render action: "standard_scores/new" }
      end
    end
  end

  # DELETE /judges/1
  # DELETE /judges/1.json
  def destroy
    ec = @judge.competition

    respond_to do |format|
      if @judge.destroy
        format.html { redirect_to competition_judges_path(ec), notice: "Judge Destroyed" }
        format.json { head :no_content }
      else
        flash[:alert] = "Unable to destroy judge"
        format.html { redirect_to competition_judges_path(ec) }
        format.json { head :no_content }
      end
    end
  end


  def create_race_official
    @user = User.find(params[:judge][:user_id])
    respond_to do |format|
      if @user.add_role(:race_official)
        format.html { redirect_to competition_judges_path(@competition), notice: 'Race Official successfully created.' }
      else
        format.html { redirect_to competition_judges_path(@competiton), alert: 'Unable to add Race Official role to user.' }
      end
    end
  end
=end
  private

  def load_new_data_entry_volunteer
    @data_entry_volunteer = DataEntryVolunteer.new
  end
end
