class Compete::AgeGroupEntriesController < ApplicationController
  include SortableObject
  before_action :authenticate_ability

  private

  def authenticate_ability
    authorize @config, :setup_competition?
  end

  def sortable_object
    @sortable_object = AgeGroupEntry.find(params[:id])
  end
end
