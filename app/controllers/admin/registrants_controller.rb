class Admin::RegistrantsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @registrants = Registrant.all
  end
end
