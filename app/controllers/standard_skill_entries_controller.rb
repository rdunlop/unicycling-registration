require 'csv'

class StandardSkillEntriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /standard_skill_entries
  def index
  end
end
