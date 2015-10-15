class PagesController < ApplicationController
  before_action :skip_authorization
  layout :determine_layout_from_params

  # GET /pages/:slug
  def show
    @page = Page.find_by!(slug: params[:slug])
  end

  private

  def determine_layout_from_params
    "minimal" if params[:framed]
  end
end
