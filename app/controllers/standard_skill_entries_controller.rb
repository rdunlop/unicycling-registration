# == Schema Information
#
# Table name: standard_skill_entries
#
#  id          :integer          not null, primary key
#  number      :integer
#  letter      :string(255)
#  points      :decimal(6, 2)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_standard_skill_entries_on_letter_and_number  (letter,number) UNIQUE
#

require 'csv'

class StandardSkillEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user

  # GET /standard_skill_entries
  def index
    # This should be visible to "all" (even not-logged in)
    @standard_skill_entries = StandardSkillEntry.all
  end

  # GET /standard_skill_entries/upload_file
  #
  def upload_file
  end

  # POST /standard_skill_entries/upload
  def upload
    StandardSkillEntry.destroy_all
    n = 0
    File.open(params[:dump][:file].tempfile, 'r:ISO-8859-1') do |f|
      f.each do |line|
        row = CSV.parse_line (line)
        # sample rows:
        # 308, 'b', '3', 'free side jump mount'
        # 308, 'c', '3.1', 'side jump mount to seat on side'
        # XXX problems:
        # No way to remove all competitors/re-import
        # no tests

        std = StandardSkillEntry.new
        std.initialize_from_array(row)
        if std.save
          n += 1
        end
      end
    end
    flash[:notice] = "CSV Import Successful,  #{n} new records added to data base"
    redirect_to standard_skill_entries_path
  end

  private

  def authorize_user
    authorize current_user, :under_development?
  end
end
