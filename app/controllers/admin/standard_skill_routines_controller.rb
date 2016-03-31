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
class Admin::StandardSkillRoutinesController < ApplicationController
  before_action :authenticate_user!

  # GET /admin/standard_skill_routines/view_all
  def view_all
    authorize StandardSkillRoutine
    @registrants = RegistrantEventSignUp.signed_up.where(event: Event.standard_skill_events).map(&:registrant)
  end

  # GET /admin/standard_skill_routines/download_file
  def download_file
    authorize StandardSkillRoutine, :export?
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
end
