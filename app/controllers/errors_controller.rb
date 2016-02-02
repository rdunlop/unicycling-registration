class ErrorsController < ApplicationController
  include Gaffe::Errors
  before_action :skip_authorization
  before_action :set_default_content_type

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

  private

  # Define content types that this controller responds to.
  #
  # The built-in responds_to was not working, so this method is used by a new
  # before action `filter_content_types` to replace it. Override this method
  # in controllers to return a list of any of:
  # :html, :css, :js, :json, :pdf, :all
  def respond_to_formats
    [:html, :all]
  end

  def set_default_content_type
    request.format = :html if respond_to_formats.exclude? request.format.symbol
  end
end
