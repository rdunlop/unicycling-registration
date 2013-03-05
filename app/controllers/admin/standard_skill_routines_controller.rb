require 'csv'
class Admin::StandardSkillRoutinesController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

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
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => filename)
  end
end
