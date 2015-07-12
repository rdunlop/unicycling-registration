class StandardSkillRoutineEntriesController < ApplicationController
  before_action :authorize_user
  before_action :load_standard_skill_routine
  before_action :load_new_standard_skill_routine_entry, only: [:create]

  # POST /standard_skill_routines/:id/standard_skill_routine_entries
  # POST /standard_skill_routines/:id/standard_skill_routine_entries.json
  def create
    # same as 'show?'

    respond_to do |format|
      if @standard_skill_routine.save
        @all_routine_entries = StandardSkillRoutine.find(@standard_skill_routine.id).standard_skill_routine_entries
        format.html { redirect_to standard_skill_routine_path(@standard_skill_routine), notice: 'StandardSkillRoutineEntry was successfully created.' }
        format.json { render json: @standard_skill_routine_entry, status: :created, location: @standard_skill_routine_entry }
        format.js
      else
        format.html { render "standard_skill_routines/show" }
        format.json { render json: @standard_skill_routine_entry.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /standard_skill_routines/:id/standard_skill_routine_entries/1
  # DELETE /standard_skill_routines/:id/standard_skill_routine_entries/1.json
  def destroy
    @standard_skill_routine_entry = @standard_skill_routine.standard_skill_routine_entries.find(params[:id])
    @standard_skill_routine_entry.destroy

    respond_to do |format|
      format.html { redirect_to standard_skill_routine_path(@standard_skill_routine) }
      format.json { head :no_content }
      format.js
    end
  end

  private

  def authorize_user
    authorize current_user, :under_development?
  end

  def load_new_standard_skill_routine_entry
    @standard_skill_routine_entry = @standard_skill_routine.add_standard_skill_routine_entry(standard_skill_routine_entry_params)
  end

  def load_standard_skill_routine
    @standard_skill_routine = StandardSkillRoutine.find(params[:standard_skill_routine_id])
  end

  def standard_skill_routine_entry_params
    params.require(:standard_skill_routine_entry).permit(:standard_skill_entry_id, :position)
  end
end
