class ResultsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: false

  def index
    respond_to do |format|
      format.html
    end
  end
end
