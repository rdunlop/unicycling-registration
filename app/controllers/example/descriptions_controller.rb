class Example::DescriptionsController < ApplicationController
  before_action :skip_authorization

  def show
    add_breadcrumb "Features", example_description_path
  end
end
