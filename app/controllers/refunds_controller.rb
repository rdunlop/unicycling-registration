# == Schema Information
#
# Table name: refunds
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  refund_date :datetime
#  note        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  percentage  :integer          default(100)
#
# Indexes
#
#  index_refunds_on_user_id  (user_id)
#

class RefundsController < ApplicationController
  before_action :authenticate_user!

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
