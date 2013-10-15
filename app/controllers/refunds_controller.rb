class RefundsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /refunds/1
  # GET /refunds/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @refund }
    end
  end
end
