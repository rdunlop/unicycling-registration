class OnsiteRegistrationController < ApplicationController
  def index
    authorize @config, :setup_convention?
  end
end
