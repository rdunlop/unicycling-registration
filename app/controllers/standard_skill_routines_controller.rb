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

class StandardSkillRoutinesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_registrant, only: [:create]
  before_action :load_standard_skill_routine, only: [:show, :writing_judge]

  # GET /standard_skill_routines
  def index
    authorize StandardSkillRoutine, :index?
    @registrants = current_user.registrants.active_or_incomplete
  end

  # POST /registrants/:id/standard_skill_routines/
  def create
    @routine = @registrant.build_standard_skill_routine
    authorize @routine

    @routine.save!

    redirect_to standard_skill_routine_path(@routine), notice: 'Standard Skill Routine Successfully Started.'
  end

  def writing_judge
    authorize @standard_skill_routine

    respond_to do |format|
      format.pdf { render_common_pdf "writing_judge", "Portrait" }
    end
  end

  # GET /standard_skill_routines/:id
  def show
    authorize @standard_skill_routine
    @entries = @standard_skill_routine.standard_skill_routine_entries
    @total = @standard_skill_routine.total_skill_points

    respond_to do |format|
      format.html # show.html.erb
      format.pdf { render_common_pdf "show", 'Portrait' }
    end
  end

  private

  def load_standard_skill_routine
    @standard_skill_routine = StandardSkillRoutine.find(params[:id])
  end

  def load_registrant
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
  end
end
