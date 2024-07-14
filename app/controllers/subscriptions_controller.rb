class SubscriptionsController < ApplicationController
  before_action :skip_authorization

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
