class ErrorsController < ApplicationController
  include Gaffe::Errors
  before_action :skip_authorization

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

  def internal_server_error
    render status: 500, layout: false
  end
end
