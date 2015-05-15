class Compete::AgeGroupEntriesController < ApplicationController
  include SortableObject
  before_action :authenticate_user!
  load_and_authorize_resource

  private

  def sortable_object
    @sortable_object = AgeGroupEntry.find(params[:id])
  end
end
