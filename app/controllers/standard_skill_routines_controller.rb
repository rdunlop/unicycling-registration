require 'csv'
class StandardSkillRoutinesController < ApplicationController
  before_action :authorize_user
  before_action :load_new_standard_skill_routine, only: [:create]
  before_action :load_registrant, only: [:create]

  # unless config.standard_skill_closed?
  #   can [:read, :create, :destroy], StandardSkillRoutine do |routine|
  #     user.registrants.include?(routine.registrant)
  #   end
  #   can :create, StandardSkillRoutine # necessary because we set the registrant in the controller?
  #   can :manage, StandardSkillRoutineEntry do |entry|
  #     can? :destroy, entry.standard_skill_routine
  #   end
  # end

  # POST /registrants/:id/standard_skill_routines/
  def create
    @routine.registrant = @registrant
    @routine.save!

    redirect_to standard_skill_routine_path(@routine), notice: 'Standard Skill Routine Successfully Started.'
  end

  # GET /standard_skill_routines/:id
  def show
    @standard_skill_routine = StandardSkillRoutine.find(params[:id])
    @entries = @standard_skill_routine.standard_skill_routine_entries
    @entry = @standard_skill_routine.standard_skill_routine_entries.build()
    @total = @standard_skill_routine.total_skill_points

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entries }
    end
  end

  # GET /standard_skill_routines
  def index
    @standard_skill_routines = StandardSkillRoutine.all
    @registrants = current_user.registrants
  end

  # GET /admin/standard_skill_routines/download_file
  def download_file
    csv_string = CSV.generate do |csv|
      csv << ['registrant_id', 'position', 'skill_number', 'skill_letter']
      StandardSkillRoutineEntry.all.each do |skill|
        csv << [skill.standard_skill_routine.registrant.external_id,
                skill.position,
                skill.standard_skill_entry.number,
                skill.standard_skill_entry.letter]
      end
    end

    filename = "standard_skills.txt"
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  private

  def authorize_user
    authorize current_user, :under_development?
  end

  def load_new_standard_skill_routine
    @routine = StandardSkillRoutine.new
  end

  def load_registrant
    @registrant = Registrant.find(params[:registrant_id])
  end
end
