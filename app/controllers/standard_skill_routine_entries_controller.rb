class StandardSkillRoutineEntriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :standard_skill_routine
  before_filter :load_new_standard_skill_routine_entry, :only => [:create]
  load_and_authorize_resource :standard_skill_routine_entry, :through => :standard_skill_routine, :only => [:destroy]

  def load_new_standard_skill_routine_entry
    @standard_skill_routine_entry = @standard_skill_routine.add_standard_skill_routine_entry(standard_skill_routine_entry_params)
  end

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
    @standard_skill_routine_entry.destroy

    respond_to do |format|
      format.html { redirect_to standard_skill_routine_path(@standard_skill_routine) }
      format.json { head :no_content }
      format.js
    end
  end

  private
  def standard_skill_routine_entry_params
    params.require(:standard_skill_routine_entry).permit(:standard_skill_entry_id, :position)
  end
end
