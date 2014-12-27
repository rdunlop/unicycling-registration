class ErrorsController < ApplicationController
  skip_authorization_check

  def not_found
    if @tenant.try(:persisted?)
      render status: 404
    else
      render status: 404, layout: false
    end
  end

  def not_permitted
    render status: 422, layout: false
  end

  def server_error
    render status: 500, layout: false
  end
end
