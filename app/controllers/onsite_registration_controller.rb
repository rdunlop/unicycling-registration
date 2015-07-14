class OnsiteRegistrationController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize @config, :setup_convention?
  end
end
