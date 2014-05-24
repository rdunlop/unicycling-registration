class AgeGroupEntriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :load_age_group_type

  respond_to :html

  def load_age_group_type
    @age_group_type = AgeGroupType.find(params[:age_group_type_id])
  end

  # GET /age_group_types/1//age_group_entries
  # GET /age_group_types/1//age_group_entries.json
  def index
    @age_group_entries = @age_group_type.age_group_entries
    @age_group_entry = AgeGroupEntry.new

    respond_with(@age_group_entries)
  end
end
