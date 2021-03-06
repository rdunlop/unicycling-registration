class AdminUpgradesController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization

  def new; end

  def create
    raise Pundit::NotAuthorizedError.new("Incorrect Access code") unless params[:access_code] == @tenant.admin_upgrade_code

    current_user.add_role :convention_admin
    flash[:notice] = "Successfully upgraded to convention_admin"
    redirect_to root_path
  end
end
