class Example::ConventionChoicesController < ApplicationController
  before_action :skip_authorization
  before_action :add_breadcrumbs

  def index; end

  private

  def add_breadcrumbs
    add_breadcrumb "Features", example_description_path
    add_breadcrumb "Registration", example_convention_choices_path
  end
end
