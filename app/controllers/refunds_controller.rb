class RefundsController < ApplicationController

  # GET /refunds/1
  # GET /refunds/1.json
  def show
    @refund = Refund.find(params[:id])
    authorize @refund
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @refund }
    end
  end
end
