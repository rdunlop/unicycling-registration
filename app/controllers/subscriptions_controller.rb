class SubscriptionsController < ApplicationController
  before_action :skip_authorization, only: [:unsubscribe]

  # GET /subscriptions
  def index
    @opt_outs = MailOptOut.where(opted_out: true).order(:email)
    authorize MailOptOut, :index?
  end

  # POST /subscribe/123
  def subscribe
    opt_out = MailOptOut.find(params[:id])
    authorize opt_out

    unless opt_out.opted_out
      render plain: "Error: User not opted out."
      return
    end

    opt_out.update(opted_out: false)
    flash[:alert] = "Updated Opt out status"
    redirect_back(fallback_location: opt_outs_path)
  end

  # GET /unsubscribe?code=abc1234
  def unsubscribe
    mail_opt_out = MailOptOut.find_by(opt_out_code: params[:code])

    if mail_opt_out.nil?
      render plain: "Unable to opt out, check link/code"
      return
    end

    mail_opt_out.update(opted_out: true)
    render plain: "Opted Out"
  end
end
