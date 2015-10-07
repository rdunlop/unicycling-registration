class PagesController < ApplicationController
  before_action :skip_authorization

  # GET /pages/:slug
  def show
    @page = Page.find_by(slug: params[:slug])
  end
end
