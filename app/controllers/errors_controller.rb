class ErrorsController < ApplicationController
  include Gaffe::Errors
  before_action :skip_authorization
  before_action :set_default_content_type
  skip_before_action :load_tenant

  def not_found
    if @tenant.try(:persisted?)
      render status: :not_found
    else
      render status: :not_found, layout: false
    end
  end

  def not_permitted
    render status: :unprocessable_entity, layout: false
  end

  def internal_server_error
    render status: :internal_server_error, layout: false
  end

  private

  # Define content types that this controller responds to.
  #
  # The built-in responds_to was not working, so this method is used by a new
  # before action `filter_content_types` to replace it. Override this method
  # in controllers to return a list of any of:
  # :html, :css, :js, :json, :pdf, :all
  def respond_to_formats
    %i[html all]
  end

  def set_default_content_type
    request.format = :html if respond_to_formats.exclude? request.format.symbol
  end
end
