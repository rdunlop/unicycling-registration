class ResultsController < ApplicationController
  skip_authorization_check only: [:index]
  # before_filter :authenticate_user!
  authorize_resource class: false

  def index
    add_breadcrumb "Results"

    respond_to do |format|
      format.html
    end
  end
end
