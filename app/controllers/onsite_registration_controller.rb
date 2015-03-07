class OnsiteRegistrationController < ApplicationController
  before_action :authenticate_user!
  authorize_resource class: false

  def index
  end
end
