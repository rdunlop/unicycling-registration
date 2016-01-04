# == Schema Information
#
# Table name: standard_skill_routines
#
#  id            :integer          not null, primary key
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_standard_skill_routines_on_registrant_id  (registrant_id) UNIQUE
#

require 'csv'
class StandardSkillRoutinesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_registrant, only: [:create]

  # POST /registrants/:id/standard_skill_routines/
  def create
    @routine = @registrant.build_standard_skill_routine
    authorize @routine

    @routine.save!

    redirect_to standard_skill_routine_path(@routine), notice: 'Standard Skill Routine Successfully Started.'
  end

  # GET /standard_skill_routines/:id
  def show
    @standard_skill_routine = StandardSkillRoutine.find(params[:id])
    authorize @standard_skill_routine
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
    authorize current_user, :under_development?
    @standard_skill_routines = StandardSkillRoutine.all
    @registrants = current_user.registrants
  end

  # GET /admin/standard_skill_routines/download_file
  def download_file
    authorize current_user, :under_development?
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

  def load_registrant
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
  end
end
